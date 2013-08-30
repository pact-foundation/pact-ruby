require 'uri'
require 'json/add/regexp'
require 'pact/logging'
require 'pact/consumer/mock_service_client'

module Pact
  module Consumer

    class ConsumerContractBuilder

      include Pact::Logging

      attr_reader :consumer_contract
      attr_reader :mock_service_client

      def initialize(attributes)
        @interactions = {}
        @provider_state = nil
        @consumer_contract = Pact::ConsumerContract.new(
          :consumer => ServiceConsumer.new(name: attributes[:consumer_name]),
          :provider => ServiceProvider.new(name: attributes[:provider_name])
          )
        @mock_service_client = MockServiceClient.new(attributes[:provider_name], attributes[:port])
        if attributes[:pactfile_write_mode] == :update && File.exist?(consumer_contract.pactfile_path)
          load_existing_interactions
        end
      end

      def load_existing_interactions
        json = File.read(consumer_contract.pactfile_path)
        if json.size > 0
          existing_consumer_contract = Pact::ConsumerContract.from_json json
          existing_consumer_contract.interactions.each do | interaction |
            @interactions["#{interaction.description} given #{interaction.provider_state}"] = interaction
          end
          consumer_contract.interactions = @interactions.values
        end
      end

      def given(provider_state)
        @provider_state = provider_state
        self
      end

      def upon_receiving(description)
        interaction_builder = InteractionBuilder.new(description, @provider_state)
        provider = self
        interaction_builder.on_interaction_fully_defined do | interaction |
          provider.handle_interaction_fully_defined(interaction)
        end
        @interactions["#{description} given #{@provider_state}"] ||= interaction_builder.interaction
        consumer_contract.interactions = @interactions.values
        interaction_builder
      end

      def handle_interaction_fully_defined interaction
        mock_service_client.add_expected_interaction interaction
        @provider_state = nil
        consumer_contract.update_pactfile
      end

      def verify example_description
        mock_service_client.verify example_description
      end

      def wait_for_interactions options
        wait_max_seconds = options.fetch(:wait_max_seconds, 3)
        poll_interval = options.fetch(:poll_interval, 0.1)
        mock_service_client.wait_for_interactions wait_max_seconds, poll_interval
      end

      private

      def filenamify name
        name.downcase.gsub(/\s/, '_')
      end

    end
  end
end
