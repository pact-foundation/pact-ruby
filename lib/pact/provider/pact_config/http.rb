# frozen_string_literal: true

require_relative "base"

module Pact
  module Provider
    module PactConfig
      class Http < Base
        attr_reader :http_port
        attr_reader :app

        def initialize(provider_name:, opts: {})
          super

          @http_port = opts[:http_port] || 0
          @app = opts[:app] || nil
        end

        def new_verifier(config = nil)
          HttpVerifier.new(self, config)
        end
      end
    end
  end
end
