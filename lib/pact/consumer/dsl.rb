require_relative 'consumer_contract_builders'

module Pact::Consumer
   module DSL
      def with_producer name, &block
         Producer.new(name, &block).create_consumer_contract_builder
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

        def create_consumer_contract_builder
          validate
          consumer_contract_builder_from_attributes
        end

        def validate
          raise "Please configure a service for #{@name}" unless @service
        end

        def consumer_contract_builder_from_attributes
          consumer_contract_builder_fields = {
            :consumer_name => Pact.configuration.consumer.name,
            :producer_name => @name,
            :pactfile_write_mode => Pact.configuration.pactfile_write_mode
            }
          @service.configure_consumer_contract_builder consumer_contract_builder_fields
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

         def configure_consumer_contract_builder consumer_contract_builder_fields
            validate
            unless @standalone
              AppManager.instance.register_mock_service_for consumer_contract_builder_fields[:producer_name], "http://localhost:#{@port}"
            end
            consumer_contract_builder = Pact::Consumer::ConsumerContractBuilder.new consumer_contract_builder_fields.merge({port: @port})
            create_mock_services_module_method consumer_contract_builder
            setup_verification(consumer_contract_builder) if @verify
            consumer_contract_builder
         end


        def setup_verification consumer_contract_builder
          Pact.configuration.add_producer_verification do | example_description |
            consumer_contract_builder.verify example_description
          end
        end

         private

         # This makes the consumer_contract_builder available via a module method with the given identifier
         # as the method name.
         # I feel this should be defined somewhere else, but I'm not sure where
         def create_mock_services_module_method consumer_contract_builder
           Pact::Consumer::ConsumerContractBuilders.send(:define_method, @name.to_sym) do
             consumer_contract_builder
           end
         end

         def validate
            raise "Please provide a port for service #{@name}" unless @port
         end
      end
   end
end

Pact.send(:extend, Pact::Consumer::DSL)