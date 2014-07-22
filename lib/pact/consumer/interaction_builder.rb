require 'net/http'
require 'pact/reification'
require 'pact/consumer_contract/interaction'
require 'pact/consumer_contract/response'

module Pact
  module Consumer
    class InteractionBuilder

      attr_reader :interaction

      def initialize
        @interaction = Interaction.new
      end

      def upon_receiving description
        @interaction.description = description
        self
      end

      def given provider_state
        @interaction.provider_state = provider_state.nil? ? nil : provider_state.to_s
        self
      end

      def with(request_details)
        interaction.request = Pact::Request::Expected.from_hash(request_details)
        self
      end

      def will_respond_with(response)
        interaction.response = Pact::Response.new(response)
        @callback.call interaction
        self
      end

      def on_interaction_fully_defined &block
        @callback = block
      end
    end
  end
end
