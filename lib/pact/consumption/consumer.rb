require_relative 'mock_producer'

module Pact
  module Consumption
    class Consumer

      def initialize name
        @name = name
      end

      def assumes_a_service(name)
        MockProducer.new(name)
      end

    end
  end
end
