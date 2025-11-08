# # frozen_string_literal: true

module Pact
  module Provider
    module PactConfig
      # Mixed config allows composing one of each: async, grpc, http
      class Mixed < Base
        attr_reader :async_config, :grpc_config, :http_config

        def initialize(provider_name:, opts: {})
          super
          @provider_setup_server = ProviderServerRunner.new(port: @provider_setup_port, logger: @logger)
          if @broker_url.present?
            @pact_proxy_server = PactBrokerProxyRunner.new(
              port: @pact_proxy_port,
              pact_broker_host: @broker_url,
              pact_broker_user: @broker_username,
              pact_broker_password: @broker_password,
              pact_broker_token: @broker_token,
              logger: @logger
            )
          end
          @http_config = opts[:http] ? Http.new(provider_name: provider_name, opts: opts[:http].merge(provider_setup_server: provider_setup_server, pact_proxy_server: @pact_proxy_server)) : nil
          @grpc_config = opts[:grpc] ? Grpc.new(provider_name: provider_name, opts: opts[:grpc].merge(provider_setup_server: provider_setup_server, pact_proxy_server: @pact_proxy_server)) : nil
          @async_config = opts[:async] ? Async.new(provider_name: provider_name, opts: opts[:async].merge(provider_setup_server: provider_setup_server, pact_proxy_server: @pact_proxy_server)) : nil
        end

        def configs
          [@async_config, @grpc_config, @http_config].compact
        end

        def start_servers
        end

      end
    end
  end
end
