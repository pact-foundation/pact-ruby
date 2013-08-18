require 'net/http'
require 'pact/reification'
require 'pact/request'
#require 'json/add/core'

module Pact
  module Consumer

    class Interaction

      attr_accessor :description, :request, :response, :producer_state

      def initialize options
        @description = options[:description]
        @request = options[:request]
        @response = options[:response]
        @producer_state = options[:producer_state]
      end

      def self.from_hash options
        new(:description => options['description'],
            :producer_state => options['producer_state'],
            :request => Pact::Request::Expected.from_hash(options['request']),
            :response => options['response']
          )
      end

      def as_json
        {
          :description => @description,
          :request => @request.as_json,
          :response => @response,
        }.tap{ | hash | hash[:producer_state] = @producer_state if @producer_state }
      end

      def to_json(options = {})
        as_json.to_json(options)
      end


      def to_json_with_generated_response
        as_json.tap { | hash | hash[:response] = Reification.from_term(response) }.to_json
      end
    end

    class InteractionBuilder

      attr_reader :interaction

      def initialize(description, producer_state)
        producer_state = producer_state.nil? ? nil : producer_state.to_s
        @interaction = Interaction.new(:description => description, :producer_state => producer_state)
      end

      def with(request_details)
        interaction.request = Request::Expected.from_hash(request_details)
        self
      end

      def will_respond_with(response)
        interaction.response = response
        @callback.call interaction
      end

      def on_interaction_fully_defined &block
        @callback = block
      end
    end
  end
end
