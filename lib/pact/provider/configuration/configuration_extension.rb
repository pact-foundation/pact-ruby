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

        def add_pact_verification verification
          pact_verifications << verification
        end

        def pact_verifications
          @pact_verifications ||= []
        end

        def config_ru_path
          @config_ru_path ||= './config.ru'
        end

        def config_ru_path= config_ru_path
          @config_ru_path = config_ru_path
        end

        def color_enabled
          # Can't use ||= when the variable might be false, it will execute the expression if it's false
          defined?(@color_enabled) ? @color_enabled : true
        end

        def color_enabled= color_enabled
          @color_enabled = color_enabled
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