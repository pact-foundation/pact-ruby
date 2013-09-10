require_relative 'pact_verification'

module Pact

   module Provider
      module DSL

         #TODO: Move this into a module, out of configuration
         module Configuration
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

         class VerificationDSL
            def initialize consumer_name, options = {}, &block
              @consumer_name = consumer_name
              @ref = options.fetch(:ref, :head)
              @pact_uri = nil
              instance_eval(&block)
            end

            def pact_uri pact_uri, options = {}
              @pact_uri = pact_uri
            end

            def task task
              @task = task
            end

            def create_verification
              validate
              Pact::Provider::PactVerification.new(@consumer_name, @pact_uri, @ref)
            end

            private

            def validate
              raise "Please provide a pact_uri for the verification" unless @pact_uri
            end

         end

         class ServiceProviderDSL

           def initialize name, &block
             @name = name
             @app = nil
             instance_eval(&block)
           end

           def validate
             raise "Please provide a name for the Provider" unless @name && !@name.strip.empty?
             raise "Please configure an app for the Provider" unless @app_block
           end

           def name name
             @name = name
           end

           def app &block
             @app_block = block
           end

           def honours_pact_with consumer_name, options = {}, &app_block
              verification = VerificationDSL.new(consumer_name, options, &app_block).create_verification
              Pact.configuration.add_pact_verification verification
           end

           def create_service_provider
             validate
             ServiceProviderConfig.new(@name, &@app_block)
           end
         end
      end
   end
end

Pact.send(:extend, Pact::Provider::DSL)