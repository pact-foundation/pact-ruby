# frozen_string_literal: true

require "pact/ffi/verifier"
require "pact/v2/native/logger"

module Pact
  module V2
    module Provider
      class GrpcVerifier < BaseVerifier
        PROVIDER_TRANSPORT_TYPE = "grpc"

        def initialize(pact_config, mixed_config = nil)
          super

          raise ArgumentError, "pact_config must be an instance of Pact::V2::Provider::PactConfig::Grpc" unless pact_config.is_a?(::Pact::V2::Provider::PactConfig::Grpc)
          @grpc_server = GrufServer.new(host: "127.0.0.1:#{@pact_config.grpc_port}", services: @pact_config.grpc_services)
        end

        private

        def add_provider_transport(pact_handle)
          PactFfi::Verifier.add_provider_transport(pact_handle, PROVIDER_TRANSPORT_TYPE, @pact_config.grpc_port, "", "")
        end


        def start_servers!
          super
          @grpc_server.start
        end

        def stop_servers
          super
          @grpc_server.stop
        end
      end
    end
  end
end
