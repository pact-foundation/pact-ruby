require 'pact/shared/dsl'

module Pact
  module Consumer
    module Configuration
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
          Pact::MockService::AppManager.instance.register app, port
        end
      end
    end
  end
end