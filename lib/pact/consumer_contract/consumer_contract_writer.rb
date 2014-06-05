require 'pact/consumer_contract'
require 'pact/consumer/interactions_filter'
require 'pact/consumer_contract/file_name'

module Pact

  class ConsumerContractWriter

    attr_reader :consumer_contract_details, :pactfile_write_mode, :interactions, :logger

    def initialize consumer_contract_details, logger
      @logger = logger
      @consumer_contract_details = consumer_contract_details
      @pactfile_write_mode = consumer_contract_details.fetch(:pactfile_write_mode, :overwrite).to_sym
      @interactions = consumer_contract_details.fetch(:interactions)
    end

    def consumer_contract
      @consumer_contract ||= Pact::ConsumerContract.new(
        consumer: ServiceConsumer.new(name: consumer_contract_details[:consumer][:name]),
        provider: ServiceProvider.new(name: consumer_contract_details[:provider][:name]),
        interactions: interactions_for_new_consumer_contract)
    end

    def write
      consumer_contract.update_pactfile
      consumer_contract.to_json
    end

    def interactions_for_new_consumer_contract
      if pactfile_write_mode == :update
        merged_interactions = existing_interactions
        filter = Consumer::UpdatableInteractionsFilter.new(merged_interactions)
        interactions.each {|i| filter << i }
        merged_interactions
      else
        interactions
      end
    end

    def existing_interactions
      interactions = []
      if pactfile_exists?
        begin
          interactions = existing_consumer_contract.interactions
          info_and_puts "*****************************************************************************"
          info_and_puts "Updating existing file .#{pactfile_path.gsub(Dir.pwd, '')} as config.pactfile_write_mode is :update"
          info_and_puts "Only interactions defined in this test run will be updated."
          info_and_puts "As interactions are identified by description and provider state, pleased note that if either of these have changed, the old interactions won't be removed from the pact file until the specs are next run with :pactfile_write_mode => :overwrite."
          info_and_puts "*****************************************************************************"
        rescue StandardError => e
          warn_and_stderr "Could not load existing consumer contract from #{pactfile_path} due to #{e}"
          logger.error e
          logger.error e.backtrace
          warn_and_stderr "Creating a new file."
        end
      end
      interactions
    end

    def pactfile_exists?
      File.exist?(pactfile_path)
    end

    def pactfile_path
      Pact::FileName.file_path consumer_contract_details[:consumer][:name], consumer_contract_details[:provider][:name]
    end

    def existing_consumer_contract
      Pact::ConsumerContract.from_uri(pactfile_path)
    end

    def warn_and_stderr msg
      Pact.configuration.error_stream.puts msg
      logger.warn msg
    end

    def info_and_puts msg
      $stdout.puts msg
      logger.info msg
    end
  end

end