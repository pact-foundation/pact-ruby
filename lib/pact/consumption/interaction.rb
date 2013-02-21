require 'net/http'
require_relative 'response'

module Pact
  module Consumption
    class Interaction

      # TODO: should not need to expose this, but a test uses it atm
      attr_reader :response

      def initialize(producer, request)
        @producer = producer
        @request = request
      end

      def will_respond_with(response)
        @response = Response.new(response)
        http = Net::HTTP.new(@producer.uri.host, @producer.uri.port)
        http.request_post('/interactions', reify.to_json)
      end

      private

      def reify
        {
          :request => @request,
          :response => @response.reify
        }
      end

    end
  end
end
