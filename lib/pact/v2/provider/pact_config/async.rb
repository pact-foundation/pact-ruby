# frozen_string_literal: true

require_relative "base"

module Pact
  module V2
    module Provider
      module PactConfig
        class Async < Base
          def initialize(provider_name:, opts: {})
            super
            handlers = opts[:message_handlers] || {}
            handlers.each do |name, block|
              new_message_handler(name, &block)
            end
          end

          def new_message_handler(name, opts: {}, &block)
            provider_setup_server.add_message_handler(name, &block)
          end

          def new_verifier(config = nil)
            AsyncMessageVerifier.new(self, config)
          end
        end
      end
    end
  end
end
