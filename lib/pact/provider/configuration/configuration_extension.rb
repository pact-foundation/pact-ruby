require 'pact/provider/state/provider_state'
require 'pact/provider/state/provider_state_configured_modules'
require 'pact/provider/state/set_up'
require 'pact/provider/state/tear_down'

module Pact

  module Provider

    module Configuration

      module ConfigurationExtension

        attr_accessor :provider_application_version

        def provider= provider
          @provider = provider
        end

        def provider
          if defined? @provider
            @provider
          else
            raise "Please configure your provider. See the Provider section in the README for examples."
          end
        end

        def config_ru_path
          @config_ru_path ||= './config.ru'
        end

        def config_ru_path= config_ru_path
          @config_ru_path = config_ru_path
        end

        def interactions_replay_order
          @interactions_replay_order ||= :recorded #or :random
        end

        def interactions_replay_order= interactions_replay_order
          @interactions_replay_order = interactions_replay_order.to_sym
        end

        def provider_state_set_up
          @provider_state_set_up ||= Pact::Provider::State::SetUp
        end

        def provider_state_set_up= provider_state_set_up
          @provider_state_set_up = provider_state_set_up
        end

        def provider_state_tear_down
          @provider_state_tear_down ||= Pact::Provider::State::TearDown
        end

        def provider_state_tear_down= provider_state_tear_down
          @provider_state_tear_down = provider_state_tear_down
        end

        def include mod
          Pact::Provider::State::ProviderStateConfiguredModules.instance_eval do
            include mod
          end
        end

      end
    end
  end
end
