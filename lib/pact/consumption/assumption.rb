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
        stub!
      end

      def stub!
        @services.each {|name, service| service.stub! }
      end

    end
  end
end
