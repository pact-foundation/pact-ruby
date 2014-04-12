require 'pact/shared/dsl'
require 'pact/consumer/configuration/mock_service'

module Pact
  module Consumer
    module Configuration
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

    end
  end

end