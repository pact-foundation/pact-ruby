# frozen_string_literal: true

module Pact
  module V2
    module Provider
      module PactConfig
        class Base
          attr_reader :provider_name, :provider_version, :log_level, :provider_setup_server, :provider_setup_port, :pact_proxy_port,
            :consumer_branch, :consumer_version, :consumer_name, :broker_url, :broker_username, :broker_password, :verify_only, :pact_dir,
            :pact_uri, :provider_version_branch, :provider_version_tags, :consumer_version_selectors, :enable_pending, :include_wip_pacts_since,
            :fail_if_no_pacts_found, :provider_build_uri, :broker_token, :consumer_version_tags, :publish_verification_results, :logger


          def initialize(provider_name:, opts: {})
            @provider_name = provider_name
            @log_level = opts[:log_level] || :info
            @pact_dir = opts[:pact_dir] || nil
            @logger = opts[:logger] || nil
            @provider_setup_port = opts[:provider_setup_port] || 9001
            @pact_proxy_port = opts[:pact_proxy_port] || 9002
            @pact_uri = ENV.fetch("PACT_URL", nil) || opts.fetch(:pact_uri, nil)
            @publish_verification_results = ENV.fetch("PACT_PUBLISH_VERIFICATION_RESULTS", nil) == "true" || opts.fetch(:publish_verification_results, false)
            @provider_version = ENV.fetch("PACT_PROVIDER_VERSION", nil) || opts.fetch(:provider_version, nil)
            @provider_build_uri = ENV.fetch("PACT_PROVIDER_BUILD_URL", nil) || opts.fetch(:provider_build_uri, nil)
            @provider_version_branch = ENV.fetch("PACT_PROVIDER_BRANCH", nil) || opts.fetch(:provider_version_branch, nil)
            @provider_version_tags = ENV.fetch("PACT_PROVIDER_VERSION_TAGS", nil) || opts.fetch(:provider_version_tags, [])
            @consumer_version_tags = ENV.fetch("PACT_CONSUMER_VERSION_TAGS", nil) || opts.fetch(:consumer_version_tags, [])
            @consumer_version_selectors = ENV.fetch("PACT_CONSUMER_VERSION_SELECTORS", nil) || opts.fetch(:consumer_version_selectors, nil)
            @enable_pending = ENV.fetch("PACT_VERIFIER_ENABLE_PENDING", nil) == "true" || opts.fetch(:enable_pending, false)
            @include_wip_pacts_since = ENV.fetch("PACT_INCLUDE_WIP_PACTS_SINCE", nil) || opts.fetch(:include_wip_pacts_since, nil)
            @fail_if_no_pacts_found = ENV.fetch("PACT_FAIL_IF_NO_PACTS_FOUND", nil) == "true" || opts.fetch(:fail_if_no_pacts_found, true)
            @consumer_branch = ENV.fetch("PACT_CONSUMER_BRANCH", nil) || opts.fetch(:consumer_branch, nil)
            @consumer_version = ENV.fetch("PACT_CONSUMER_VERSION", nil) || opts.fetch(:consumer_version, nil)
            @consumer_name = opts[:consumer_name]
            @broker_url = ENV.fetch("PACT_BROKER_BASE_URL", nil) || opts.fetch(:broker_url, nil)
            @broker_username = ENV.fetch("PACT_BROKER_USERNAME", nil) || opts.fetch(:broker_username, nil)
            @broker_password = ENV.fetch("PACT_BROKER_PASSWORD", nil) || opts.fetch(:broker_password, nil)
            @broker_token = ENV.fetch("PACT_BROKER_TOKEN", nil) || opts.fetch(:broker_token, nil)
            @verify_only = [ENV.fetch("PACT_CONSUMER_FULL_NAME", nil)].compact || opts.fetch(:verify_only, [])

            @provider_setup_server = opts[:provider_setup_server] || ProviderServerRunner.new(port: @provider_setup_port, logger: @logger)
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
          end


          def start_servers
            @provider_setup_server.start
            @pact_proxy_server&.start
          end

          def stop_servers
            @provider_setup_server.stop
            @pact_proxy_server&.stop
          end

          def provider_setup_url
            @provider_setup_server.state_setup_url
          end

          def message_setup_url # rubocop:disable Rails/Delegate
            @provider_setup_server.message_setup_url
          end

          def pact_broker_proxy_url
            @pact_proxy_server&.proxy_url
          end

          def new_provider_state(name, opts: {}, &block)
            config = ProviderStateConfiguration.new(name, opts: opts)
            config.instance_eval(&block)
            config.validate!

            use_hooks = !opts[:skip_hooks]

            @provider_setup_server.add_setup_state(name, use_hooks, &config.setup_proc) if config.setup_proc
            @provider_setup_server.add_teardown_state(name, use_hooks, &config.teardown_proc) if config.teardown_proc
          end

          def before_setup(&block)
            @provider_setup_server.set_before_setup_hook(&block)
          end

          def after_teardown(&block)
            @provider_setup_server.set_after_teardown_hook(&block)
          end

          def new_verifier
            raise Pact::V2::ImplementationRequired, "#new_verifier should be implemented"
          end
        end
      end
    end
  end
end
