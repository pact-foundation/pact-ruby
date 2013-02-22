require 'uri'

module Pact
  module Consumption
    class MockProducer

      attr_reader :uri, :pact_path

      def initialize(name, pact_path)
        @name = name
        @pact_path = pact_path
        @interactions = []
      end

      def at(url)
        @uri = URI(url)
        self
      end

      def upon_receiving(request)
        Interaction.new(self, request).tap { |int| @interactions << int }
      end

    end
  end
end
