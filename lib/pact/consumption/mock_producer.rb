module Pact
  module Consumption
    class MockProducer
      def initialize url
        @url = url
        @interactions = []
      end

      def when_requested_with request
        interaction = Interaction.new(request)
        @interactions << interaction
        interaction
      end

      def stub!
        uri = URI.parse @url
        http = Net::HTTP.new(uri.host, uri.port)
        http.request_put('/interactions', to_reified_hash.to_json)
      end

      def to_reified_hash
        {
          :interactions => @interactions.map(&:to_reified_hash)
        }
      end

      def to_hash
        {
          :interactions => @interactions.map(&:to_hash)
        }
      end

    end
  end
end
