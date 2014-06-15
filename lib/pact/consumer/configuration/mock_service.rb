require 'pact/consumer/app_manager'
require 'pact/consumer/consumer_contract_builder'
require 'pact/consumer/consumer_contract_builders'
require 'pact/consumer/world'

module Pact
  module Consumer
    module Configuration
      class MockService

        extend Pact::DSL

        attr_accessor :port, :standalone, :verify, :provider_name, :consumer_name

        def initialize name, consumer_name, provider_name
          @name = name
          @consumer_name = consumer_name
          @provider_name = provider_name
          @port = nil
          @standalone = false
          @verify = true
        end

        dsl do
          def port port
            self.port = port
          end

          def standalone standalone
            self.standalone = standalone
          end

          def verify verify
            self.verify = verify
          end
        end

        def finalize
          validate
          register_mock_service
          configure_consumer_contract_builder
        end

        private

        def register_mock_service
          unless standalone
            AppManager.instance.new_register_mock_service_for provider_name, "http://localhost:#{port}"
          end
        end

        def configure_consumer_contract_builder
          consumer_contract_builder = create_consumer_contract_builder
          create_consumer_contract_builders_method consumer_contract_builder
          setup_verification(consumer_contract_builder) if verify
          consumer_contract_builder
        end

        def create_consumer_contract_builder
          consumer_contract_builder_fields = {
            :consumer_name => consumer_name,
            :provider_name => provider_name,
            :pactfile_write_mode => Pact.configuration.pactfile_write_mode,
            :port => port
          }
          Pact::Consumer::ConsumerContractBuilder.new consumer_contract_builder_fields
        end

        def setup_verification consumer_contract_builder
          Pact.configuration.add_provider_verification do | example_description |
            consumer_contract_builder.verify example_description
          end
        end

         # This makes the consumer_contract_builder available via a module method with the given identifier
         # as the method name.
         # I feel this should be defined somewhere else, but I'm not sure where
        def create_consumer_contract_builders_method consumer_contract_builder
          Pact::Consumer::ConsumerContractBuilders.send(:define_method, @name.to_sym) do
            consumer_contract_builder
          end
          Pact.consumer_world.add_consumer_contract_builder consumer_contract_builder
        end

        def validate
          raise "Please provide a port for service #{name}" unless port
        end
      end
    end
  end
end