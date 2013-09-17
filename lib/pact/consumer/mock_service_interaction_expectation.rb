require 'pact/reification'

# Represents the Interaction in the form required by the MockService
# The json generated will be posted to the MockService to register the expectation
module Pact
  module Consumer
    class MockServiceInteractionExpectation


      def initialize interaction
        @interaction = interaction
      end

      def as_json
        hash = {:description => interaction.description}
        hash[:provider_state] = interaction.provider_state if interaction.provider_state
        hash[:request] = interaction.request.as_json_with_options
        hash[:response] = Reification.from_term(interaction.response)
        hash
      end

      def to_json opts = {}
        as_json.to_json(opts)
      end

      private

      attr_reader :interaction

    end
  end
end