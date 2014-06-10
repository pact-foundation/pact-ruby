require 'uri'
require 'json/add/regexp'
require 'pact/logging'
require 'pact/consumer/mock_service_client'
require 'pact/consumer/interaction_builder'

module Pact
  module Consumer

    class ConsumerContractBuilder

      include Pact::Logging

      attr_reader :consumer_contract, :mock_service_base_url

      def initialize(attributes)
        @interaction_builder = nil
        @consumer_contract_details = {
          consumer: {name: attributes[:consumer_name]},
          provider: {name: attributes[:provider_name]},
          pactfile_write_mode: attributes[:pactfile_write_mode].to_s
        }
        @mock_service_client = MockServiceClient.new(attributes[:port])
        @mock_service_base_url = "http://localhost:#{attributes[:port]}"
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

      def log msg
        mock_service_client.log msg
      end

      def write_pact
        mock_service_client.write_pact @consumer_contract_details
      end

      def wait_for_interactions options
        wait_max_seconds = options.fetch(:wait_max_seconds, 3)
        poll_interval = options.fetch(:poll_interval, 0.1)
        mock_service_client.wait_for_interactions wait_max_seconds, poll_interval
      end

      def handle_interaction_fully_defined interaction
        mock_service_client.add_expected_interaction interaction #TODO: What will happen if duplicate added?
        self.interaction_builder = nil
      end

      private

      attr_reader :mock_service_client
      attr_writer :interaction_builder

      # def interactions_for_new_consumer_contract pactfile_write_mode
      #   pactfile_write_mode == :update ? existing_interactions : []
      # end

      # def filter interactions, pactfile_write_mode
      #   if pactfile_write_mode == :update
      #     UpdatableInteractionsFilter.new(interactions)
      #   else
      #     DistinctInteractionsFilter.new(interactions)
      #   end
      # end

      # def warn_and_stderr msg
      #   Pact.configuration.error_stream.puts msg
      #   logger.warn msg
      # end

      # def info_and_puts msg
      #   $stdout.puts msg
      #   logger.info msg
      # end

      # def existing_interactions
      #   interactions = []
      #   if pactfile_exists?
      #     begin
      #       interactions = existing_consumer_contract.interactions
      #       info_and_puts "*****************************************************************************"
      #       info_and_puts "Updating existing file .#{consumer_contract.pactfile_path.gsub(Dir.pwd, '')} as config.pactfile_write_mode is :update"
      #       info_and_puts "Only interactions defined in this test run will be updated."
      #       info_and_puts "As interactions are identified by description and provider state, pleased note that if either of these have changed, the old interactions won't be removed from the pact file until the specs are next run with :pactfile_write_mode => :overwrite."
      #       info_and_puts "*****************************************************************************"
      #     rescue StandardError => e
      #       warn_and_stderr "Could not load existing consumer contract from #{consumer_contract.pactfile_path} due to #{e}"
      #       warn_and_stderr "Creating a new file."
      #     end
      #   end
      #   interactions
      # end

      # def pactfile_exists?
      #   File.exist?(consumer_contract.pactfile_path)
      # end

      # def existing_consumer_contract
      #   Pact::ConsumerContract.from_uri(consumer_contract.pactfile_path)
      # end

    end
  end
end
