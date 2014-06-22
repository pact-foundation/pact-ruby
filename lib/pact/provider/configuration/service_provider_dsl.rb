require 'pact/provider/configuration/pact_verification'
require 'pact/provider/configuration/service_provider_config'

module Pact

  module Provider

    module Configuration

      class ServiceProviderDSL

        extend Pact::DSL

        attr_accessor :name, :app_block

        CONFIG_RU_APP = lambda {
          unless File.exist? Pact.configuration.config_ru_path
            raise "Could not find config.ru file at #{Pact.configuration.config_ru_path} Please configure the service provider app or create a config.ru file in the root directory of the project. See https://github.com/realestate-com-au/pact/blob/master/documentation/verifying-pacts.md for more information."
          end
          Rack::Builder.parse_file(Pact.configuration.config_ru_path).first
        }

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