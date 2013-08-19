module Pact

   module Producer
      module DSL

         module Configuration
            def provider= provider
               @producer = provider
            end
         end

         Pact::Configuration.send(:include, Configuration)

         def service_provider name, &block
            service_provider = ServiceProviderDSL.new(name, &block).create_service_provider
            Pact.configuration.provider = service_provider
            service_provider
         end

        class ServiceProviderConfig
           attr_accessor :name

           def initialize name, &app_block
             @name = name
             @app_block = app_block
           end

           def app
             @app_block.call
           end
         end

         class ServiceProviderDSL

           def initialize name, &block
             @name = name
             @app = nil
             instance_eval(&block)
           end

           def validate
             raise "Please provide a name for the Producer" unless @name
             raise "Please configure an app for the Producer" unless @app_block
           end

           def name name
             @name = name
           end

           def app &block
             @app_block = block
           end

           def create_service_provider
             validate
             ServiceProviderConfig.new(@name, &@app_block)
           end
         end
      end
   end
end
