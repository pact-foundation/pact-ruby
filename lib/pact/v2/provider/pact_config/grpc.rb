# frozen_string_literal: true

require_relative "base"

module Pact
  module V2
    module Provider
      module PactConfig
        class Grpc < Base
          attr_reader :grpc_port, :grpc_services, :grpc_server

          def initialize(provider_name:, opts: {})
            super

            @grpc_port = opts[:grpc_port] || 0
            @grpc_services = opts[:grpc_services] || []
          end

          def new_verifier(config = nil)
            GrpcVerifier.new(self, config)
          end
        end
      end
    end
  end
end
