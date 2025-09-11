# frozen_string_literal: true

require "pact/ffi/message_consumer"
require "pact/ffi/plugin_consumer"
require "pact/ffi/logger"

module Pact
  module V2
    module Consumer
      class MessageInteractionBuilder
        META_CONTENT_TYPE_HEADER = "contentType"

        JSON_CONTENT_TYPE = "application/json"
        PROTO_CONTENT_TYPE = "application/protobuf"

        PROTOBUF_PLUGIN_NAME = "protobuf"
        PROTOBUF_PLUGIN_VERSION = "0.6.5"

        # https://docs.rs/pact_ffi/latest/pact_ffi/mock_server/handles/fn.pactffi_write_message_pact_file.html
        WRITE_PACT_FILE_ERRORS = {
          1 => {reason: :file_not_accessible, status: 1, description: "The pact file was not able to be written"},
          2 => {reason: :internal_error, status: 2, description: "The message pact for the given handle was not found"}
        }.freeze

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
          @description = description

          @json_contents = nil
          @proto_contents = nil
          @proto_path = nil
          @proto_message_class = nil
          @proto_include_dirs = []
          @meta = {}
          @headers = {}
          @provider_state_meta = nil
        end

        def given(provider_state, metadata = {})
          @provider_state_meta = {provider_state => metadata}
          self
        end

        def upon_receiving(description)
          @description = description
          self
        end

        def with_json_contents(contents_hash)
          @json_contents = InteractionContents.basic(contents_hash)
          self
        end

        def with_proto_class(proto_path, message_class_name, include_dirs = [])
          absolute_path = File.expand_path(proto_path)
          raise InteractionBuilderError.new("proto file #{proto_path} does not exist") unless File.exist?(absolute_path)

          @proto_path = absolute_path
          @proto_message_class = message_class_name
          @proto_include_dirs = include_dirs.map { |dir| File.expand_path(dir) }
          self
        end

        def with_proto_contents(contents_hash)
          @proto_contents = InteractionContents.plugin(contents_hash)
          self
        end

        def with_metadata(meta_hash)
          @meta = InteractionContents.basic(meta_hash)
          self
        end

        def with_headers(headers_hash)
          @headers = InteractionContents.basic(headers_hash)
          self
        end

        def with_header(key, value)
          @headers[key] = value
          self
        end

        def validate!
          if proto_interaction?
            raise InteractionBuilderError.new("proto_path / proto_message are not defined, please set ones with #with_proto_message") if @proto_contents.blank? || @proto_message_class.blank?
            raise InteractionBuilderError.new("invalid request format, should be a hash") unless @proto_contents.is_a?(Hash)
          else
            raise InteractionBuilderError.new("invalid request format, should be a hash") unless @json_contents.is_a?(Hash)
          end
          raise InteractionBuilderError.new("description is required for message interactions, please set one with #upon_receiving") if @description.blank?
        end

        def execute(&block)
          raise InteractionBuilderError.new("interaction is designed to be used one-time only") if defined?(@used)

          validate!
          pact_handle = init_pact
          init_plugin!(pact_handle) if proto_interaction?

          message_pact = PactFfi::MessageConsumer.new_message_interaction(pact_handle, @description)

          configure_interaction!(message_pact)

          # strip out matchers and get raw payload/metadata
          payload, metadata = fetch_reified_message(pact_handle)
          configure_provider_state(message_pact, metadata)

          yield(payload, metadata)

          write_pacts!(pact_handle, @pact_config.pact_dir)
        ensure
          @used = true
          PactFfi::MessageConsumer.free_handle(message_pact)
          PactFfi.free_pact_handle(pact_handle)
        end

        def build_interaction_json
          return JSON.dump(@json_contents) unless proto_interaction?

          contents = {
            "pact:proto": @proto_path,
            "pact:message-type": @proto_message_class,
            "pact:content-type": PROTO_CONTENT_TYPE
          }.merge(@proto_contents)

          contents["pact:protobuf-config"] = {additionalIncludes: @proto_include_dirs} if @proto_include_dirs.present?

          JSON.dump(contents)
        end

        private

        def write_pacts!(handle, dir)
          result = PactFfi.write_message_pact_file(handle, @pact_config.pact_dir, false)
          return result if WRITE_PACT_FILE_ERRORS[result].blank?

          error = WRITE_PACT_FILE_ERRORS[result]
          raise WritePactsError.new("There was an error while trying to write pact file to #{dir}", error[:reason], error[:status])
        end

        def init_pact
          handle = PactFfi::MessageConsumer.new_message_pact(@pact_config.consumer_name, @pact_config.provider_name)
          PactFfi.with_specification(handle, PactFfi::FfiSpecificationVersion["SPECIFICATION_VERSION_V4"])
          PactFfi.with_pact_metadata(handle, "pact-ruby-v2", "pact-ffi", PactFfi.version)

          Pact::V2::Native::Logger.log_to_stdout(@pact_config.log_level)

          handle
        end

        def fetch_reified_message(pact_handle)
          iterator = PactFfi::MessageConsumer.pact_handle_get_message_iter(pact_handle)
          raise InteractionBuilderError.new("cannot get message iterator: internal error") if iterator.blank?

          message_handle = PactFfi.pact_message_iter_next(iterator)
          raise InteractionBuilderError.new("cannot get message from iterator: no messages") if message_handle.blank?

          contents = fetch_reified_message_body(message_handle)
          meta = fetch_reified_message_headers(message_handle)

          [contents, meta.compact]
        ensure
          PactFfi.pact_message_iter_delete(iterator) if iterator.present?
        end

        def fetch_reified_message_headers(message_handle)
          meta = {"headers" => {}}

          meta[META_CONTENT_TYPE_HEADER] = PactFfi.message_find_metadata(message_handle, META_CONTENT_TYPE_HEADER)

          @meta.each_key do |key|
            meta[key.to_s] = PactFfi.message_find_metadata(message_handle, key.to_s)
          end

          @headers.each_key do |key|
            meta["headers"][key.to_s] = PactFfi.message_find_metadata(message_handle, key.to_s)
          end

          meta
        end

        def configure_provider_state(message_pact, reified_metadata)
          content_type = reified_metadata[META_CONTENT_TYPE_HEADER]
          @provider_state_meta&.each_pair do |provider_state, meta|
            if meta.present?
              meta.each_pair { |k, v| PactFfi.given_with_param(message_pact, provider_state, k.to_s, v.to_s) }
              PactFfi.given_with_param(message_pact, provider_state, META_CONTENT_TYPE_HEADER, content_type.to_s) if content_type
            elsif content_type.present?
              PactFfi.given_with_param(message_pact, provider_state, META_CONTENT_TYPE_HEADER, content_type.to_s)
            else
              PactFfi.given(message_pact, provider_state)
            end
          end
        end

        def fetch_reified_message_body(message_handle)
          if proto_interaction?
            len = PactFfi::MessageConsumer.get_contents_length(message_handle)
            ptr = PactFfi::MessageConsumer.get_contents_bin(message_handle)
            return nil if ptr.blank? || len == 0

            return String.new(ptr.read_string_length(len))
          end

          contents = PactFfi::MessageConsumer.get_contents(message_handle)
          return nil if contents.blank?

          JSON.parse(contents)
        end

        def configure_interaction!(message_pact)
          interaction_json = build_interaction_json

          if proto_interaction?
            result = PactFfi::PluginConsumer.interaction_contents(message_pact, 0, PROTO_CONTENT_TYPE, interaction_json)
            if CREATE_INTERACTION_ERRORS[result].present?
              error = CREATE_INTERACTION_ERRORS[result]
              raise CreateInteractionError.new("There was an error while trying to add interaction \"#{@description}\"", error[:reason], error[:status])
            end
          else
            result = PactFfi.with_body(message_pact, 0, JSON_CONTENT_TYPE, interaction_json)
            unless result
              raise InteractionMismatchesError.new("There was an error while trying to add message interaction contents \"#{@description}\"")
            end
          end

          # meta should be configured last to avoid resetting after body is set
          InteractionContents.basic(@meta.merge(@headers)).each_pair do |key, value|
            PactFfi::MessageConsumer.with_metadata_v2(message_pact, key.to_s, JSON.dump(value))
          end
        end

        def init_plugin!(pact_handle)
          result = PactFfi::PluginConsumer.using_plugin(pact_handle, PROTOBUF_PLUGIN_NAME, PROTOBUF_PLUGIN_VERSION)
          return result if INIT_PLUGIN_ERRORS[result].blank?

          error = INIT_PLUGIN_ERRORS[result]
          raise PluginInitError.new("There was an error while trying to initialize plugin #{PROTOBUF_PLUGIN_NAME}/#{PROTOBUF_PLUGIN_VERSION}", error[:reason], error[:status])
        end

        def serialize_metadata(metadata_hash)
          metadata = metadata_hash.deep_dup
          serialize_as!(metadata, :basic)

          metadata
        end

        def proto_interaction?
          @proto_contents.present?
        end
      end
    end
  end
end
