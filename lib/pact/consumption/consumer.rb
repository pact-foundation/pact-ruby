require_relative 'assumption'
require_relative 'mock_producer'

module Pact
  module Consumption
    class Consumer

      def initialize name
        @name = name
        @assumptions = []
      end

      def assumes &block
        assumption = Assumption.new(
          :contract_service => MockProducer.new(MOCK_CONTRACT_SERVICE_URL)
        )
        assumption.assume(&block)
        @assumptions << assumption
      end

    end
  end
end
