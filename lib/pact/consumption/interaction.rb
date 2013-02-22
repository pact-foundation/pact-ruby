require 'net/http'
require_relative 'response'

module Pact
  module Consumption
    class Interaction

      def initialize(producer, request)
        @producer = producer
        @request = request
        @http = Net::HTTP.new(@producer.uri.host, @producer.uri.port)
      end

      def will_respond_with(response)
        @response = Response.new(response)
        @http.request_post('/interactions', reify.to_json)
        @producer.update_pactfile
        @producer
      end

      def to_json
        {
          :request => @request,
          :response => @response.to_json
        }
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
