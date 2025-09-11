# frozen_string_literal: true

require "pact/ffi/verifier"
require "pact/v2/native/logger"

module Pact
  module V2
    module Provider
      class HttpVerifier < BaseVerifier
        PROVIDER_TRANSPORT_TYPE = "http"

        def initialize(pact_config, mixed_config = nil)
          super

          raise ArgumentError, "pact_config must be an instance of Pact::V2::Provider::PactConfig::Http" unless pact_config.is_a?(::Pact::V2::Provider::PactConfig::Http)
          @http_server = HttpServer.new(host: "127.0.0.1", port: @pact_config.http_port, app: @pact_config.app)
        end

        private

        def set_provider_info(pact_handle)
          PactFfi::Verifier.set_provider_info(pact_handle, @pact_config.provider_name, "", "", @pact_config.http_port, "")
        end

        def add_provider_transport(pact_handle)
          # The http transport is already added when the `set_provider_info` method is called,
          # so we don't need to explicitly add the transport here
        end


        def start_servers!
          super
          @http_server.start
        end

        def stop_servers
          super
          @http_server.stop
        end
      end
    end
  end
end
