require 'pact/consumer/configuration/service_consumer'

module Pact
  module Consumer
    module DSL
      def service_consumer name, &block
        Configuration::ServiceConsumer.build(name, &block)
      end
    end
  end
end