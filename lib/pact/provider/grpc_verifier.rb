# frozen_string_literal: true

require 'pact/ffi/verifier'
require 'pact/native/logger'

module Pact
  module Provider
    class GrpcVerifier < BaseVerifier
      PROVIDER_TRANSPORT_TYPE = 'grpc'

      def initialize(pact_config, mixed_config = nil)
        super

        unless pact_config.is_a?(::Pact::Provider::PactConfig::Grpc)
          raise ArgumentError,
                'pact_config must be an instance of Pact::Provider::PactConfig::Grpc'
        end

        @grpc_server = GrufServer.new(host: "127.0.0.1:#{@pact_config.grpc_port}",
                                      services: @pact_config.grpc_services, logger: @pact_config.logger)
      end

      private

      def add_provider_transport(pact_handle)
        PactFfi::Verifier.add_provider_transport(pact_handle, PROVIDER_TRANSPORT_TYPE, @pact_config.grpc_port, '', '')
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
