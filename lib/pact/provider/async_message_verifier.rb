# frozen_string_literal: true

require 'pact/ffi/verifier'
require 'pact/native/logger'

module Pact
  module Provider
    class AsyncMessageVerifier < BaseVerifier
      PROVIDER_TRANSPORT_TYPE = 'message'

      def initialize(pact_config, mixed_config = nil)
        super

        return if pact_config.is_a?(::Pact::Provider::PactConfig::Async)

        raise ArgumentError,
              'pact_config must be an instance of Pact::Provider::PactConfig::Message'
      end

      private

      def add_provider_transport(pact_handle)
        setup_uri = URI(@pact_config.message_setup_url)
        PactFfi::Verifier.add_provider_transport(pact_handle, PROVIDER_TRANSPORT_TYPE, setup_uri.port, setup_uri.path,
                                                 '')
      end
    end
  end
end
