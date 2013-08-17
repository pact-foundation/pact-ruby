require_relative 'mock_producers'

module Pact::Consumer
   module DSL
      def with_producer name, &block
         Producer.new(name, &block).create_mock_producer
      end

      class Producer
         def initialize name, &block
            @name = name
            @service = nil
            instance_eval(&block)
         end

         def service name, &block
            @service = Service.new(name, &block)
         end

         alias_method :mock_service, :service

        def create_mock_producer
          validate
          mock_producer_from_attributes
        end

        def validate
          raise "Please configure a service for #{@name}" unless @service
        end

        def mock_producer_from_attributes
          mock_producer = Pact::Consumer::MockProducer.new(Pact.configuration.pact_dir).
            consumer(Pact.configuration.consumer.name).
              assuming_a_service(@name)
          @service.configure_mock_producer mock_producer, @name
        end
      end

      class Service
         def initialize name, &block
            @name = name
            @port = nil
            @standalone = false
            @verify = false            
            instance_eval(&block)
         end

         def port port
            @port = port
         end

         def standalone standalone
            @standalone = standalone
         end

         def verify verify
            @verify = verify
         end         

         def configure_mock_producer mock_producer, producer_name
            validate
            unless @standalone
              AppManager.instance.register_mock_service_for producer_name, "http://localhost:#{@port}"
            end
            mock_producer.on_port(@port)
            create_mock_services_module_method mock_producer
            setup_verification(mock_producer) if @verify
            mock_producer
         end

        def setup_verification mock_producer
          Pact.configuration.add_producer_verification do
            mock_producer.verify
          end
        end         

         private

         # This makes the mock_producer available via a module method with the given identifier
         # as the method name.
         # I feel this should be defined somewhere else, but I'm not sure where
         def create_mock_services_module_method mock_producer
           Pact::Consumer::MockProducers.send(:define_method, @name.to_sym) do
             mock_producer
           end
         end

         def validate
            raise "Please provide a port for service #{@name}" unless @port
         end
      end
   end
end

Pact.send(:extend, Pact::Consumer::DSL)