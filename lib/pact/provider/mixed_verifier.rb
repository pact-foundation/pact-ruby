# # frozen_string_literal: true
module Pact
  module Provider
    # MixedVerifier coordinates verification for all present configs (async, grpc, http)
    class MixedVerifier
      attr_reader :mixed_config, :verifiers

      def initialize(mixed_config)
        unless mixed_config.is_a?(::Pact::Provider::PactConfig::Mixed)
          raise ArgumentError, 'mixed_config must be a PactConfig::Mixed'
        end

        @mixed_config = mixed_config
        @verifiers = []
        @verifiers << AsyncMessageVerifier.new(mixed_config.async_config) if mixed_config.async_config
        @verifiers << GrpcVerifier.new(mixed_config.grpc_config) if mixed_config.grpc_config
        @verifiers << HttpVerifier.new(mixed_config.http_config) if mixed_config.http_config
      end
    end
  end
end
