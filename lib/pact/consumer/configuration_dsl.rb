require_relative 'service_consumer'
require_relative 'mock_producers'

module Pact
  module Consumer
    module ConfigurationDSL

      def producer identifier, &block
        mock_producer = ProducerDSL.new(identifier, &block).create_mock_producer
        producers << mock_producer
      end

      def producers
        @producers ||= []
      end

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
          instance_eval(&block)
        end

        def validate
          raise "Please provide a consumer name" unless @name
        end

        def name name
          @name = name
        end

        def create_service_consumer
          validate
          Pact::Consumer::ServiceConsumer.new name: @name
        end
      end

      class ProducerDSL

        def initialize identifier, &block
          @identifier = identifier
          @standalone = false
          instance_eval(&block)
        end

        def validate
          raise "Please provide a port for #{@identifier}" unless @port
          raise "Please provide a name for #{@identifier}" unless @name
        end

        def create_mock_producer
          validate
          mock_producer = mock_consumer_from_attributes
          create_mock_services_module_method mock_producer
          mock_producer
        end

        # This makes the mock_producer available via a module method with the given identifier
        # as the method name.
        # I feel this should be defined somewhere else, but I'm not sure where
        def create_mock_services_module_method mock_producer
          Pact::Consumer::MockProducers.send(:define_method, @identifier.to_sym) do
            mock_producer
          end
        end

        def port port
          @port = port
        end

        def name name
          @name = name
        end

        def standalone standalone
          @standalone = standalone
        end

        def to_s
          "#{@identifier} #{@name} #{@port} #{@standalone}"
        end

        private

        def mock_consumer_from_attributes
          Pact::Consumer::MockProducer.new(Pact.configuration.pact_dir).
            consumer(Pact.configuration.consumer.name).
              assuming_a_service(@name).
                on_port(@port, standalone: @standalone)
        end
      end
    end
  end
end
