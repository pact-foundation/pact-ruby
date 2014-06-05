require 'pact/reification'

# Represents the Interaction in the form required by the MockService
# The json generated will be posted to the MockService to register the expectation
module Pact
  module Consumer
    class MockServiceInteractionExpectation


      def initialize interaction
        @interaction = interaction
      end

      def to_hash
        hash = {:description => interaction.description}
        hash[:provider_state] = interaction.provider_state if interaction.provider_state
        options = interaction.request.options.empty? ? {} : { options: interaction.request.options}
        hash[:request] = interaction.request.as_json.merge(options)
        hash[:response] = interaction.response
        hash
      end

      def as_json options = {}
        to_hash
      end

      def to_json opts = {}
        as_json.to_json(opts)
      end

      private

      attr_reader :interaction

    end
  end
end