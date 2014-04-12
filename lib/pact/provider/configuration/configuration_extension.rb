require 'pact/provider/state/provider_state'
require 'pact/provider/state/provider_state_configured_modules'
require 'pact/matchers/plus_minus_diff_decorator'
require 'pact/matchers/nested_json_diff_formatter'
require 'pact/matchers/list_of_paths_diff_formatter'

module Pact

  module Provider

    module Configuration

      module ConfigurationExtension

        DIFF_FORMATTERS = {
          :nested_json => Pact::Matchers::NestedJsonDiffFormatter,
          :plus_and_minus => Pact::Matchers::PlusMinusDiffDecorator,
          :list_of_paths => Pact::Matchers::ListOfPathsDiffFormatter
        }

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

        def diff_formatter
          @diff_formatter ||= DIFF_FORMATTERS[:nested_json]
        end

        def diff_formatter= diff_formatter
          @diff_formatter = begin
            if DIFF_FORMATTERS[diff_formatter]
              DIFF_FORMATTERS[diff_formatter]
            elsif diff_formatter.respond_to?(:call)
              diff_formatter
            else
              raise "Pact.configuration.diff_formatter needs to respond to call, or be in the preconfigured list: #{DIFF_FORMATTERS.keys}"
            end
          end
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