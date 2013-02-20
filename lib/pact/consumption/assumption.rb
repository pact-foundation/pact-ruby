module Pact
  module Consumption
    class Assumption

      def initialize services = {}
        @services = services
      end

      def service name
        @services[name]
      end

      def assume
        yield self
        @services.each { |name, service| service.stub! }
      end

    end
  end
end
