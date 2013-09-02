require 'uri'
require 'json/add/regexp'
require 'pact/logging'
require 'pact/consumer/mock_service_client'
require_relative 'interactions_filter'

module Pact
  module Consumer

    class ConsumerContractBuilder

      include Pact::Logging

      attr_reader :consumer_contract

      def initialize(attributes)
        @interaction_builder = nil
        @mock_service_client = MockServiceClient.new(attributes[:provider_name], attributes[:port])
        @consumer_contract = Pact::ConsumerContract.new(
          :consumer => ServiceConsumer.new(name: attributes[:consumer_name]),
          :provider => ServiceProvider.new(name: attributes[:provider_name])
          )
        @consumer_contract.interactions = interactions_for_new_consumer_contract(attributes[:pactfile_write_mode])
        @interactions_filter = filter(@consumer_contract.interactions, attributes[:pactfile_write_mode])
      end

      def given(provider_state)
        interaction_builder.given(provider_state)
      end

      def upon_receiving(description)
        interaction_builder.upon_receiving(description)
      end

      def interaction_builder
        @interaction_builder ||=
        begin
          interaction_builder = InteractionBuilder.new
          interaction_builder.on_interaction_fully_defined do | interaction |
            self.handle_interaction_fully_defined(interaction)
          end
          interaction_builder
        end
      end

      def verify example_description
        mock_service_client.verify example_description
      end

      def wait_for_interactions options
        wait_max_seconds = options.fetch(:wait_max_seconds, 3)
        poll_interval = options.fetch(:poll_interval, 0.1)
        mock_service_client.wait_for_interactions wait_max_seconds, poll_interval
      end

      def handle_interaction_fully_defined interaction
        interactions_filter << interaction
        mock_service_client.add_expected_interaction interaction #TODO: What will happen if duplicate added?
        consumer_contract.update_pactfile
        self.interaction_builder = nil
      end

      private

      attr_reader :mock_service_client
      attr_reader :interactions_filter
      attr_writer :interaction_builder

      def interactions_for_new_consumer_contract pactfile_write_mode
        pactfile_write_mode == :update ? existing_interactions : []
      end

      def filter interactions, pactfile_write_mode
        if pactfile_write_mode == :update
          UpdatableInteractionsFilter.new(interactions)
        else
          DistinctInteractionsFilter.new(interactions)
        end
      end

      def log_and_puts msg
        $stderr.puts msg
        logger.warn msg
      end

      def existing_interactions
        interactions = []
        if pactfile_exists?
          begin
            interactions = existing_consumer_contract.interactions
          rescue StandardError => e
            log_and_puts "Could not load existing consumer contract from #{consumer_contract.pactfile_path} due to #{e}"
            log_and_puts "Creating a new file."
          end
        end
        interactions
      end

      def pactfile_exists?
        File.exist?(consumer_contract.pactfile_path)
      end

      def existing_consumer_contract
        Pact::ConsumerContract.from_json(File.read(consumer_contract.pactfile_path))
      end

    end
  end
end
