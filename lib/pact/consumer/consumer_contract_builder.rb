require 'uri'
require 'json/add/regexp'
require 'pact/logging'
require 'pact/consumer/mock_service_client'
require_relative 'interactions'

module Pact
  module Consumer

    class ConsumerContractBuilder

      include Pact::Logging

      attr_reader :consumer_contract
      attr_reader :mock_service_client

      def initialize(attributes)
        @provider_state = nil
        @mock_service_client = MockServiceClient.new(attributes[:provider_name], attributes[:port])
        @consumer_contract = Pact::ConsumerContract.new(
          :consumer => ServiceConsumer.new(name: attributes[:consumer_name]),
          :provider => ServiceProvider.new(name: attributes[:provider_name])
          )
        interactions = if attributes[:pactfile_write_mode] == :update
          UpdatableInteractions.new(existing_interactions)
        else
          DistinctInteractions.new
        end
        @consumer_contract.interactions = interactions
      end

      def existing_interactions
        interactions = []
        if pactfile_exists?
          json = existing_consumer_contract_json
          if json.size > 0
            begin
              existing_consumer_contract = Pact::ConsumerContract.from_json json
              interactions = existing_consumer_contract.interactions
            rescue StandardError => e
              log_and_puts "Could not load existing consumer contract from #{consumer_contract.pactfile_path} due to #{e}"
              log_and_puts "Creating a new file."
            end
          end
        end
        interactions
      end

      def pactfile_exists?
        File.exist?(consumer_contract.pactfile_path)
      end

      def existing_consumer_contract_json
        File.read(consumer_contract.pactfile_path)
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
        interaction_builder
      end

      def handle_interaction_fully_defined interaction
        consumer_contract.interactions << interaction
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

      def log_and_puts msg
        $stderr.puts msg
        logger.warn msg
      end

    end
  end
end
