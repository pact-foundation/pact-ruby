require 'pact/configuration'
require 'pact/consumer/consumer_contract_builders'
require 'pact/consumer/consumer_contract_builder'
require 'pact/shared/dsl'

module Pact::Consumer

  module DSL
    def service_consumer name, &block
      Configuration::ServiceConsumer.build(name, &block)
    end
  end

  module Configuration

    module ConfigurationExtensions
      def add_provider_verification &block
        provider_verifications << block
      end
      def provider_verifications
        @provider_verifications ||= []
      end
    end

    class ServiceConsumer
      extend Pact::DSL
      attr_accessor :app, :port, :name

      def initialize name
        @name = name
        @app = nil
        @port = nil
      end

      dsl do
        def app app
          self.app = app
        end

        def port port
          self.port = port
        end

        def has_pact_with service_provider_name, &block
          ServiceProvider.build(service_provider_name, name, &block)
        end
      end

      def finalize
        validate
        register_consumer_app if @app
      end

      private

      def validate
        raise "Please provide a consumer name" unless (name && !name.empty?)
        raise "Please provide a port for the consumer app" if app && !port
      end


      def register_consumer_app
        Pact::Consumer::AppManager.instance.register app, port
      end
    end


    class ServiceProvider
      extend Pact::DSL

      attr_accessor :service, :consumer_name, :name

      def initialize name, consumer_name
        @name = name
        @service = nil
        @consumer_name = consumer_name
      end

      dsl do
        def mock_service name, &block
          self.service = MockService.build(name, consumer_name, self.name, &block)
        end
      end

      def finalize
        validate
      end

      private

      def validate
        raise "Please configure a service for #{name}" unless service
      end

    end

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
          AppManager.instance.register_mock_service_for provider_name, "http://localhost:#{port}"
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
      end

      def validate
        raise "Please provide a port for service #{name}" unless port
      end
    end
  end
end

Pact.send(:extend, Pact::Consumer::DSL)
Pact::Configuration.send(:include, Pact::Consumer::Configuration::ConfigurationExtensions)