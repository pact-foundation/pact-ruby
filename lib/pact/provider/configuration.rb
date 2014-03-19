require 'pact/provider/pact_verification'
require 'pact/shared/dsl'
require 'pact/provider/state/provider_state'
require 'pact/provider/state/provider_state_configured_modules'

module Pact

  module Provider

    module DSL
      def service_provider name, &block
        Configuration::ServiceProviderDSL.build(name, &block)
      end
    end

    Pact.send(:extend, Pact::Provider::DSL)
    Pact.send(:extend, Pact::Provider::State::DSL)

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

      Pact::Configuration.send(:include, ConfigurationExtension)

      class ServiceProviderConfig

        def initialize &app_block
          @app_block = app_block
        end

        def app
          @app_block.call
        end
      end

      class PactVerification
        extend Pact::DSL

        attr_accessor :consumer_name, :pact_uri, :ref

        def initialize consumer_name, options = {}
          @consumer_name = consumer_name
          @ref = options.fetch(:ref, :head)
          @pact_uri = nil
        end

        dsl do
          def pact_uri pact_uri
            self.pact_uri = pact_uri
          end
        end

        def finalize
          validate
          create_pact_verification
        end

        private

        def create_pact_verification
          verification = Pact::Provider::PactVerification.new(consumer_name, pact_uri, ref)
          Pact.configuration.add_pact_verification verification
        end

        def validate
          raise "Please provide a pact_uri for the verification" unless pact_uri
        end

      end

      class ServiceProviderDSL
        extend Pact::DSL

        attr_accessor :name, :app_block

        CONFIG_RU_APP = lambda { Rack::Builder.parse_file(Pact.configuration.config_ru_path).first }

        def initialize name
          @name = name
          @app_block = CONFIG_RU_APP
        end

        dsl do
          def app &block
            self.app_block = block
          end

          def honours_pact_with consumer_name, options = {}, &block
            create_pact_verification consumer_name, options, &block
          end
        end

        def create_pact_verification consumer_name, options, &block
          PactVerification.build(consumer_name, options, &block)
        end

        def finalize
          validate
          create_service_provider
        end

        private

        def validate
          raise "Please provide a name for the Provider" unless name && !name.strip.empty?
        end

        def create_service_provider
          Pact.configuration.provider = ServiceProviderConfig.new(&@app_block)
        end
      end
    end
  end
end
