require 'pact/reification'
require 'pact/consumer/hypermediafy_object_tree'

# Represents the Interaction in the form required by the MockService
# The json generated will be posted to the MockService to register the expectation
module Pact
  module Consumer
    class MockServiceInteractionExpectation


      def initialize interaction, mock_service_host
        @interaction = interaction
        @mock_service_host = mock_service_host
      end

      def to_hash
        hash = {:description => interaction.description}
        hash[:provider_state] = interaction.provider_state if interaction.provider_state
        options = interaction.request.options.empty? ? {} : { options: interaction.request.options}
        hash[:request] = interaction.request.as_json.merge(options)
        hash[:response] = interaction.response
        response_options = (interaction.response.delete(:options) || {})
        if response_options[:host_alias]
          Pact::HypermediafyObjectTree.call(hash, response_options[:host_alias], @mock_service_host)
        else
          hash
        end
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