require 'net/http'
require 'pact/reification'
require 'pact/request'
require 'json/add/core'

module Pact
  module Consumer
    class Interaction

      def initialize(producer, description, producer_state)
        @producer = producer
        @description = description
        @producer_state = producer_state.is_a?(Symbol) ? producer_state.to_s : producer_state
        @http = Net::HTTP.new(@producer.uri.host, @producer.uri.port)
      end

      def will_respond_with(response_terms)
        @response_terms = response_terms
        @http.request_post('/interactions', with_generated_response.to_json)
        @producer.update_pactfile
        @producer
      end

      def with(request_details)
        @request = Request::Expected.from_hash(request_details)
        self
      end

      def as_json
        {
          :description => @description,
          :request => @request.as_json,
          :response => @response_terms,
        }.tap{ | hash | hash[:producer_state] = @producer_state if @producer_state }
      end

      def to_json(options = {})
        as_json.to_json(options)
      end

      private

      def with_generated_response
        as_json.tap { | hash | hash[:response] = Reification.from_term(@response_terms) }
      end

    end
  end
end
