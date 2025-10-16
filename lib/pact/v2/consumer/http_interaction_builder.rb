# frozen_string_literal: true

require "pact/ffi/sync_message_consumer"
require "pact/ffi/plugin_consumer"
require "pact/ffi/logger"
require "json"

module Pact
  module V2
    module Consumer
      class HttpInteractionBuilder

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

        class << self
          def create_finalizer(pact_handle)
            proc { PactFfi.free_pact_handle(pact_handle) }
          end
        end

        def initialize(pact_config, description: nil)
          @pact_config = pact_config
          @description = description || ""

          @pact_handle = pact_config.pact_handle ||= init_pact
          @pact_interaction = PactFfi.new_interaction(pact_handle, @description)

          ObjectSpace.define_finalizer(self, self.class.create_finalizer(pact_interaction))
        end

        def given(provider_state, metadata = {})
          if metadata.present?
            PactFfi.given_with_params(pact_interaction, provider_state, JSON.dump(metadata))
          else
            PactFfi.given(pact_interaction, provider_state)
          end

          self
        end

        def upon_receiving(description)
          @description = description
          PactFfi.upon_receiving(pact_interaction, @description)
          self
        end

        def with_request(method: nil, path: nil, query: {}, headers: {}, body: nil)
          interaction_part = PactFfi::FfiInteractionPart["INTERACTION_PART_REQUEST"]
          PactFfi.with_request(pact_interaction, method.to_s, format_value(path))

          # Processing as an array of hashes, allows us to consider duplicate keys
          # which should be passed to the core, at a non 0 index
          if query.is_a?(Array)
            key_index = Hash.new(0)
            query.each do |query_item|
              InteractionContents.basic(query_item).each_pair do |key, value_item|
                PactFfi.with_query_parameter_v2(pact_interaction, key.to_s, key_index[key], format_value(value_item))
                key_index[key] += 1
              end
            end
          else
            InteractionContents.basic(query).each_pair do |key, value_item|
              PactFfi.with_query_parameter_v2(pact_interaction, key.to_s, 0, format_value(value_item))
            end
          end

          InteractionContents.basic(headers).each_pair do |key, value_item|
            PactFfi.with_header_v2(pact_interaction, interaction_part, key.to_s, 0, format_value(value_item))
          end

          if body
            PactFfi.with_body(pact_interaction, interaction_part, "application/json", format_value(InteractionContents.basic(body)))
          end

          self
        end

        def will_respond_with(status: nil, headers: {}, body: nil)
          interaction_part = PactFfi::FfiInteractionPart["INTERACTION_PART_RESPONSE"]
          PactFfi.response_status(pact_interaction, status)

          InteractionContents.basic(headers).each_pair do |key, value_item|
            PactFfi.with_header_v2(pact_interaction, interaction_part, key.to_s, 0, format_value(value_item))
          end

          if body
            PactFfi.with_body(pact_interaction, interaction_part, "application/json", format_value(InteractionContents.basic(body)))
          end

          self
        end

        def execute(&block)
          raise InteractionBuilderError.new("interaction is designed to be used one-time only") if defined?(@used)

          mock_server = MockServer.create_for_http!(
            pact: pact_handle, host: pact_config.mock_host, port: pact_config.mock_port
          )

          yield(mock_server)

        ensure
          if mock_server.matched?
            mock_server.write_pacts!(pact_config.pact_dir)
          else
            msg = mismatches_error_msg(mock_server)
            raise InteractionMismatchesError.new(msg)
          end
          @used = true
          mock_server&.cleanup
          # Reset the pact handle to allow for a new interaction to be built
          # without previous interactions being included
          @pact_config.reset_pact
        end

        private

        attr_reader :pact_handle, :pact_interaction, :pact_config

        def mismatches_error_msg(mock_server)
          rspec_example_desc = RSpec.current_example&.description
          mismatches = JSON.pretty_generate(JSON.parse(mock_server.mismatches))
          mismatches_with_colored_keys = mismatches.gsub(/"([^"]+)":/) { |match| "\e[34m#{match}\e[0m" } # Blue keys / white values

          "#{rspec_example_desc} has mismatches: #{mismatches_with_colored_keys}"
        end

        def init_pact
          handle = PactFfi.new_pact(pact_config.consumer_name, pact_config.provider_name)
          PactFfi.with_specification(handle, PactFfi::FfiSpecificationVersion["SPECIFICATION_VERSION_#{pact_config.pact_specification}"])
          PactFfi.with_pact_metadata(handle, "pact-ruby-v2", "pact-ffi", PactFfi.version)

          Pact::V2::Native::Logger.log_to_stdout(pact_config.log_level)

          handle
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
