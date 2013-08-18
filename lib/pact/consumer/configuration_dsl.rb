require_relative 'service_consumer'
require_relative 'consumer_contract_builders'
require_relative '../configuration'

module Pact
  module Consumer


    module Configuration
      def add_producer_verification &block
        producer_verifications << block
      end
      def producer_verifications
        @producer_verifications ||= []
      end
    end

    module ConfigurationDSL

      def consumer &block
        if block_given?
          @consumer = ConsumerDSL.new(&block).create_service_consumer
        elsif @consumer
          @consumer
        else
          raise "Please configure a consumer before configuring producers"
        end
      end

      class ConsumerDSL

        def initialize &block
          @app = nil
          @port = nil
          @name = nil
          instance_eval(&block)
        end

        def validate
          raise "Please provide a consumer name" unless @name
          raise "Please provide a port for the consumer app" if @app && !@port
        end

        def name name
          @name = name
        end

        def app app
          @app = app
        end

        def port port
          @port = port
        end

        def create_service_consumer
          validate
          register_consumer_app if @app
          Pact::Consumer::ServiceConsumer.new name: @name
        end

        def register_consumer_app
          Pact::Consumer::AppManager.instance.register @app, @port
        end
      end
    end
  end
end

Pact::Configuration.send(:include, Pact::Consumer::ConfigurationDSL)
Pact::Configuration.send(:include, Pact::Consumer::Configuration)
