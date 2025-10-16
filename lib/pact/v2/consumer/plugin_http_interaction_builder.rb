# frozen_string_literal: true

require "pact/ffi/http_consumer"
require "pact/ffi/plugin_consumer"
require "pact/ffi/logger"

module Pact
  module V2
    module Consumer
      class PluginHttpInteractionBuilder

        class PluginInitError < Pact::V2::FfiError; end

        # https://docs.rs/pact_ffi/0.4.17/pact_ffi/plugins/fn.pactffi_using_plugin.html
        INIT_PLUGIN_ERRORS = {
          1 => {reason: :internal_error, status: 1, description: "A general panic was caught"},
          2 => {reason: :plugin_load_failed, status: 2, description: "Failed to load the plugin"},
          3 => {reason: :invalid_handle, status: 3, description: "Pact Handle is not valid"}
        }.freeze

        # https://docs.rs/pact_ffi/0.4.17/pact_ffi/plugins/fn.pactffi_interaction_contents.html
        CREATE_INTERACTION_ERRORS = {
          1 => {reason: :internal_error, status: 1, description: "A general panic was caught"},
          2 => {reason: :mock_server_already_running, status: 2, description: "The mock server has already been started"},
          3 => {reason: :invalid_handle, status: 3, description: "The interaction handle is invalid"},
          4 => {reason: :invalid_content_type, status: 4, description: "The content type is not valid"},
          5 => {reason: :invalid_contents, status: 5, description: "The contents JSON is not valid JSON"},
          6 => {reason: :plugin_error, status: 6, description: "The plugin returned an error"}
        }.freeze

        class CreateInteractionError < Pact::V2::FfiError; end

        class InteractionMismatchesError < Pact::V2::Error; end

        class InteractionBuilderError < Pact::V2::Error; end

        def initialize(pact_config, description: nil)
          @pact_config = pact_config
          @description = description || ""
          @contents = nil
          @provider_state_meta = nil
        end

        def with_plugin(plugin_name, plugin_version)
          raise InteractionBuilderError.new("plugin_name is required") if plugin_name.blank?
          raise InteractionBuilderError.new("plugin_version is required") if plugin_version.blank?

          @plugin_name = plugin_name
          @plugin_version = plugin_version
          self
        end

        def given(provider_state, metadata = {})
          @provider_state_meta = {provider_state => metadata}
          self
        end

        def upon_receiving(description)
          @description = description
          self
        end

        def with_request(method: nil, path: nil, query: {}, headers: {}, body: nil)
          @request = {
            method: method,
            path: path,
            query: query,
            headers: headers,
            body: body
          }
          self
        end

        def will_respond_with(status: nil, headers: {}, body: nil)
          @response = {
            status: status,
            headers: headers,
            body: body
          }
          self
        end
  
        def with_content_type(content_type)
          @content_type = content_type
          self
        end


        def with_plugin_metadata(meta_hash)
          @plugin_metadata = meta_hash
          self
        end

        def with_transport(transport)
          @transport = transport
          self
        end

        def interaction_json
          result = {
            request: @request,
            response: @response
          }
          result.merge!(@plugin_metadata) if @plugin_metadata.is_a?(Hash)
          JSON.dump(result)
        end

        def validate!
          raise InteractionBuilderError.new("invalid request format, should be a hash") unless @request.is_a?(Hash)
          raise InteractionBuilderError.new("invalid response format, should be a hash") unless @response.is_a?(Hash)
        end

        def execute(&block)
          raise InteractionBuilderError.new("interaction is designed to be used one-time only") if defined?(@used)

          validate!

          pact_handle = init_pact
          init_plugin!(pact_handle)

          interaction = PactFfi.new_interaction(pact_handle, @description)
          @provider_state_meta&.each_pair do |provider_state, meta|
            if meta.present?
                meta.each_pair do |k, v|
                if v.nil? || (v.respond_to?(:empty?) && v.empty?)
                  PactFfi.given(interaction, provider_state)
                else
                  PactFfi.given_with_param(interaction, provider_state, k.to_s, v.to_s)
                end
                end
            else
              PactFfi.given(interaction, provider_state)
            end
          end
          PactFfi::HttpConsumer.with_request(interaction, @request[:method], @request[:path])

          result = PactFfi::PluginConsumer.interaction_contents(interaction, 0, @request[:headers]["content-type"], format_value(@request[:body]))
          if CREATE_INTERACTION_ERRORS[result].present?
            error = CREATE_INTERACTION_ERRORS[result]
            raise CreateInteractionError.new("There was an error while trying to add interaction \"#{@description}\"", error[:reason], error[:status])
          end
          result = PactFfi::PluginConsumer.interaction_contents(interaction, 1, @response[:headers]["content-type"], format_value(@response[:body]))
          if CREATE_INTERACTION_ERRORS[result].present?
            error = CREATE_INTERACTION_ERRORS[result]
            raise CreateInteractionError.new("There was an error while trying to add interaction \"#{@description}\"", error[:reason], error[:status])
          end
          mock_server = MockServer.create_for_transport!(pact: pact_handle, transport: @transport || 'http', host: @pact_config.mock_host, port: @pact_config.mock_port)
          
          yield(mock_server)

        ensure
          if mock_server.matched?
            mock_server.write_pacts!(@pact_config.pact_dir)
          else
            msg = mismatches_error_msg(mock_server)
            raise InteractionMismatchesError.new(msg)
          end
          @used = true
          mock_server&.cleanup
          PactFfi::PluginConsumer.cleanup_plugins(pact_handle) if pact_handle
          PactFfi.free_pact_handle(pact_handle) if pact_handle
        end

        private

        def mismatches_error_msg(mock_server)
          rspec_example_desc = RSpec.current_example&.description
          return "interaction for has mismatches: #{mock_server.mismatches}" if rspec_example_desc.blank?

          "#{rspec_example_desc} has mismatches: #{mock_server.mismatches}"
        end

        def init_pact
          handle = PactFfi.new_pact(@pact_config.consumer_name, @pact_config.provider_name)
          PactFfi.with_specification(handle, PactFfi::FfiSpecificationVersion["SPECIFICATION_VERSION_V4"])
          PactFfi.with_pact_metadata(handle, "pact-ruby-v2", "pact-ffi", PactFfi.version)

          Pact::V2::Native::Logger.log_to_stdout(@pact_config.log_level)

          handle
        end

        def init_plugin!(pact_handle)
          result = PactFfi::PluginConsumer.using_plugin(pact_handle, @plugin_name, @plugin_version)
          return result if INIT_PLUGIN_ERRORS[result].blank?

          error = INIT_PLUGIN_ERRORS[result]
          raise PluginInitError.new("There was an error while trying to initialize plugin #{@plugin_name}/#{@plugin_version}", error[:reason], error[:status])
        end

        def format_value(obj)
          return obj if obj.is_a?(String)

          return JSON.dump({value: obj}) if obj.is_a?(Array)

          JSON.dump(obj)
        end
      end
    end
  end
end
