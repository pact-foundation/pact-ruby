# frozen_string_literal: true

require "webrick"

module Pact
  module V2
    module Provider
      class MessageProviderServlet < WEBrick::HTTPServlet::ProcHandler
        attr_reader :logger

        CONTENT_TYPE_JSON = "application/json"
        CONTENT_TYPE_PROTO = "application/protobuf"
        METADATA_HEADER = "pact-message-metadata"

        def initialize(logger: nil)
          super(build_proc)

          @message_handlers = {}

          @logger = logger || Logger.new($stdout)
        end

        def add_message_handler(name, &block)
          raise "message handler for #{name} already configured" if @message_handlers[name].present?

          @message_handlers[name] = {proc: block}
        end

        private

        def build_proc
          proc do |request, response|
            # {"description":"message: ","providerStates":[{"name":"pet exists","params":{"pet_id":1}}]}
            data = JSON.parse(request.body)

            description = data["description"]
            provider_states = data["providerStates"]

            body, metadata = handle(description, provider_states)

            response.status = 200
            if body.is_a?(String)
              # protobuf-serialized body
              response.body = body
              response.content_type = metadata[:content_type] || CONTENT_TYPE_PROTO
            else
              response.body = body.to_json
              response.content_type = CONTENT_TYPE_JSON
            end
            response[METADATA_HEADER] = Base64.urlsafe_encode64(metadata.to_json)
          rescue JSON::ParserError => ex
            logger.error("cannot parse request: #{ex.message}")
            response.status = 500
          rescue => ex
            logger.error("cannot handle message request: #{ex.message}")
            response.status = 500
          end
        end

        def handle(description, provider_states)
          handler = find_handler_for(description)
          return {}, {} unless handler

          body, metadata = handler[:proc].call(provider_states&.first || {})
          unless metadata[:content_type]
            # try to find content-type in provider states
            content_type = provider_states&.filter_map { |state| state.dig("params", "contentType") }&.first
            metadata[:content_type] = content_type if content_type
          end
          [body, metadata]
        end

        def find_handler_for(description)
          @message_handlers[description]
        end
      end
    end
  end
end
