module Pact
  module Consumer
    class MockServiceClient
      def initialize name, port
        @http = Net::HTTP.new('localhost', port)
      end

      def verify example_description
        response = http.request_get("/verify?example_description=#{URI.encode(example_description)}")
        raise response.body unless response.is_a? Net::HTTPSuccess
      end

      def clear_interactions example_description
        http.delete("/interactions?example_description=#{URI.encode(example_description)}")
      end

      def add_expected_interaction interaction
        http.request_post('/interactions', interaction.to_json_with_generated_response)
      end

      def self.clear_interactions port, example_description
        Net::HTTP.new("localhost", port).delete("/interactions?example_description=#{URI.encode(example_description)}")
      end

      private
      attr_reader :http
    end
  end
end