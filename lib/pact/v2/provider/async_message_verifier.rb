# frozen_string_literal: true

require "pact/ffi/verifier"
require "pact/v2/native/logger"

module Pact
  module V2
    module Provider
      class AsyncMessageVerifier < BaseVerifier
        PROVIDER_TRANSPORT_TYPE = "message"

        def initialize(pact_config, mixed_config = nil)
          super

          raise ArgumentError, "pact_config must be an instance of Pact::V2::Provider::PactConfig::Message" unless pact_config.is_a?(::Pact::V2::Provider::PactConfig::Async)
        end

        private

        def add_provider_transport(pact_handle)
          setup_uri = URI(@pact_config.message_setup_url)
          PactFfi::Verifier.add_provider_transport(pact_handle, PROVIDER_TRANSPORT_TYPE, setup_uri.port, setup_uri.path, "")
        end

      end
    end
  end
end
