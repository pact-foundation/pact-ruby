require 'pact/provider/state/provider_state'
require 'pact/provider/state/provider_state_configured_modules'

module Pact

  module Provider

    module Configuration

      module ConfigurationExtension

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

        def include mod
          Pact::Provider::State::ProviderStateConfiguredModules.instance_eval do
            include mod
          end
        end

      end
    end
  end
end