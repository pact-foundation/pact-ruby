# frozen_string_literal: true

require "pact/ffi/sync_message_consumer"
require "pact/ffi/plugin_consumer"
require "pact/ffi/logger"

module Pact
  module V2
    module Consumer
      class GrpcInteractionBuilder
        CONTENT_TYPE = "application/protobuf"
        GRPC_CONTENT_TYPE = "application/grpc"
        PROTOBUF_PLUGIN_NAME = "protobuf"
        PROTOBUF_PLUGIN_VERSION = "0.6.5"

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
          @proto_path = nil
          @proto_include_dirs = []
          @service_name = nil
          @method_name = nil
          @request = nil
          @response = nil
          @response_meta = nil
          @provider_state_meta = nil
        end

        def with_service(proto_path, method, include_dirs = [])
          raise InteractionBuilderError.new("invalid grpc method: cannot be blank") if method.blank?

          service_name, method_name = method.split("/") || []
          raise InteractionBuilderError.new("invalid grpc method: #{method}, should be like service/SomeMethod") if service_name.blank? || method_name.blank?

          absolute_path = File.expand_path(proto_path)
          raise InteractionBuilderError.new("proto file #{proto_path} does not exist") unless File.exist?(absolute_path)

          @proto_path = absolute_path
          @service_name = service_name
          @method_name = method_name
          @proto_include_dirs = include_dirs.map { |dir| File.expand_path(dir) }

          self
        end

        def with_pact_protobuf_plugin_version(version)
          raise InteractionBuilderError.new("version is required") if version.blank?

          @proto_plugin_version = version
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

        def with_request(req_hash)
          @request = InteractionContents.plugin(req_hash)
          self
        end

        def will_respond_with(resp_hash)
          @response = InteractionContents.plugin(resp_hash)
          self
        end

        def will_respond_with_meta(meta_hash)
          @response_meta = InteractionContents.plugin(meta_hash)
          self
        end

        def interaction_json
          result = {
            "pact:proto": @proto_path,
            "pact:proto-service": "#{@service_name}/#{@method_name}",
            "pact:content-type": CONTENT_TYPE,
            request: @request
          }

          result["pact:protobuf-config"] = {additionalIncludes: @proto_include_dirs} if @proto_include_dirs.present?

          result[:response] = @response if @response.is_a?(Hash)
          result[:responseMetadata] = @response_meta if @response_meta.is_a?(Hash)

          JSON.dump(result)
        end

        def validate!
          raise InteractionBuilderError.new("uninitialized service params, use #with_service to configure") if @proto_path.blank? || @service_name.blank? || @method_name.blank?
          raise InteractionBuilderError.new("invalid request format, should be a hash") unless @request.is_a?(Hash)
          raise InteractionBuilderError.new("invalid response format, should be a hash") unless @response.is_a?(Hash) || @response_meta.is_a?(Hash)
        end

        def execute(&block)
          raise InteractionBuilderError.new("interaction is designed to be used one-time only") if defined?(@used)

          validate!

          pact_handle = init_pact
          init_plugin!(pact_handle)

          message_pact = PactFfi::SyncMessageConsumer.new_interaction(pact_handle, @description)
          @provider_state_meta&.each_pair do |provider_state, meta|
            if meta.present?
              meta.each_pair { |k, v| PactFfi.given_with_param(message_pact, provider_state, k.to_s, v.to_s) }
            else
              PactFfi.given(message_pact, provider_state)
            end
          end

          result = PactFfi::PluginConsumer.interaction_contents(message_pact, 0, GRPC_CONTENT_TYPE, interaction_json)
          if CREATE_INTERACTION_ERRORS[result].present?
            error = CREATE_INTERACTION_ERRORS[result]
            raise CreateInteractionError.new("There was an error while trying to add interaction \"#{@description}\"", error[:reason], error[:status])
          end

          mock_server = MockServer.create_for_grpc!(pact: pact_handle, host: @pact_config.mock_host, port: @pact_config.mock_port)

          yield(message_pact, mock_server)

        ensure
          if mock_server.matched?
            mock_server.write_pacts!(@pact_config.pact_dir)
          else
            msg = mismatches_error_msg(mock_server)
            raise InteractionMismatchesError.new(msg)
          end
          @used = true
          mock_server&.cleanup
          PactFfi::PluginConsumer.cleanup_plugins(pact_handle)
          PactFfi.free_pact_handle(pact_handle)
        end

        private

        def mismatches_error_msg(mock_server)
          rspec_example_desc = RSpec.current_example&.description
          return "interaction for #{@service_name}/#{@method_name} has mismatches: #{mock_server.mismatches}" if rspec_example_desc.blank?

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
          result = PactFfi::PluginConsumer.using_plugin(pact_handle, PROTOBUF_PLUGIN_NAME, @proto_plugin_version || PROTOBUF_PLUGIN_VERSION)
          return result if INIT_PLUGIN_ERRORS[result].blank?

          error = INIT_PLUGIN_ERRORS[result]
          raise PluginInitError.new("There was an error while trying to initialize plugin #{PROTOBUF_PLUGIN_NAME}/#{@proto_plugin_version || PROTOBUF_PLUGIN_VERSION}", error[:reason], error[:status])
        end
      end
    end
  end
end
