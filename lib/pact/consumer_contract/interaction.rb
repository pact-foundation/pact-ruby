require 'pact/request'

module Pact
   class Interaction

      attr_accessor :description, :request, :response, :provider_state

      def initialize attributes
        @description = attributes[:description]
        @request = attributes[:request]
        @response = attributes[:response]
        @provider_state = attributes[:provider_state]
      end

      def self.from_hash hash
        new(:description => hash['description'],
            :provider_state => hash['provider_state'],
            :request => Pact::Request::Expected.from_hash(hash['request']),
            :response => hash['response']
          )
      end

      def as_json
        {
          :description => @description,
          :request => @request.as_json,
          :response => @response,
        }.tap{ | hash | hash[:provider_state] = @provider_state if @provider_state }
      end

      def to_json(options = {})
        as_json.to_json(options)
      end

      def as_json_for_mock_service
        {:response => Reification.from_term(response), :request => @request.as_json_with_options, :description => description }.
          tap{ | hash | hash[:provider_state] = @provider_state if @provider_state }
      end

      def to_json_for_mock_service
        as_json_for_mock_service.to_json
      end
   end
end