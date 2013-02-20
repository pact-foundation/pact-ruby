module Pact
  module Consumer
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

      def stub!
        @services.each {|name, service| service.stub! }
      end

    end
  end
end
