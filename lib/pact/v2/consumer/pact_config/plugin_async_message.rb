# frozen_string_literal: true

require_relative "base"

module Pact
  module V2
    module Consumer
      module PactConfig
        class PluginAsyncMessage < Base
          attr_reader :mock_host, :mock_port

          def initialize(consumer_name:, provider_name:, opts: {})
            super

            @mock_host = opts[:mock_host] || "127.0.0.1"
            @mock_port = opts[:mock_port] || 0
          end

          def new_interaction(description = nil)
            PluginAsyncMessageInteractionBuilder.new(self, description: description)
          end
        end
      end
    end
  end
end
