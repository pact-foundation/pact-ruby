require 'net/http'
require_relative 'generate_response'

module Pact
  module Consumption
    class Interaction

      def initialize(producer, request)
        @producer = producer
        @request = request
        @http = Net::HTTP.new(@producer.uri.host, @producer.uri.port)
      end

      def will_respond_with(response_spec)
        @response_spec = response_spec
        @http.request_post('/interactions', with_generated_response.to_json)
        @producer.update_pactfile
        @producer
      end

      def to_json
        {
          :request => @request,
          :response => @response_spec
        }
      end

      private

      def with_generated_response
        {
          :request => @request,
          :response => GenerateResponse.from_specification(@response_spec)
        }
      end

    end
  end
end
