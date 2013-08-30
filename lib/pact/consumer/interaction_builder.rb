require 'net/http'
require 'pact/reification'
require 'pact/request'
require 'pact/consumer_contract/interaction'

module Pact
  module Consumer
    class InteractionBuilder

      attr_reader :interaction

      def initialize(description, provider_state)
        provider_state = provider_state.nil? ? nil : provider_state.to_s
        @interaction = Interaction.new(:description => description, :provider_state => provider_state)
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
