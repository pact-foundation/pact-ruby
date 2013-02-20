module Pact
  module Consumption
    class Consumer

      def initialize name
        @name = name
        @assumptions = []
      end

      def assumes &block
        assumption = Assumption.new(
          :contract_service => ProducerMock.new(MOCK_CONTRACT_SERVICE_URL)
        )
        assumption.assume(&block)
        @assumptions << assumption
      end

    end
  end
end
