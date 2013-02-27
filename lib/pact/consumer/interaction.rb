require 'net/http'
require_relative 'generate_response'

module Pact
  module Consumer
    class Interaction

      def initialize(producer, description)
        @producer = producer
        @description = description
        @http = Net::HTTP.new(@producer.uri.host, @producer.uri.port)
      end

      def will_respond_with(response_terms)
        @response_terms = response_terms
        @http.request_post('/interactions', with_generated_response.to_json)
        @producer.update_pactfile
        @producer
      end

      def with(request)
        @request = request
        @request[:method] = @request[:method].to_s if @request[:method]
        self
      end

      def to_json(options = {})
        {
          :description => @description,
          :request => @request,
          :response => @response_terms
        }.to_json(options)
      end

      private

      def with_generated_response
        {
          :description => @description,
          :request => @request,
          :response => GenerateResponse.from_term(@response_terms)
        }
      end

    end
  end
end
