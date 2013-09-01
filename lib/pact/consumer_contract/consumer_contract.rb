require 'pact/consumer_contract'
require 'pact/logging'
require 'pact/json_warning'
require 'date'
require 'pact/version'
require_relative 'service_consumer'
require_relative 'service_provider'
require_relative 'interaction'

module Pact
  class ConsumerContract

    include Pact::Logging
    include Pact::JsonWarning

    attr_accessor :interactions
    attr_accessor :consumer
    attr_accessor :provider

    def initialize(attributes = {})
      @interactions = attributes[:interactions] || []
      @consumer = attributes[:consumer]
      @provider = attributes[:provider]
    end

    def as_json(options = {})
      {
        provider: @provider.as_json,
        consumer: @consumer.as_json,
        interactions: @interactions.collect(&:as_json),
        metadata: {
          pact_gem: {
            version: Pact::VERSION
          }
        }
      }
    end

    def to_json(options = {})
      as_json(options).to_json(options)
    end

    def self.from_hash(obj)
      new({
        :interactions => obj['interactions'].collect { |hash| Interaction.from_hash(hash)},
        :consumer => ServiceConsumer.from_hash(obj['consumer']),
        :provider => ServiceProvider.from_hash(obj['provider'] || {})
      })
    end

    def self.from_json string
      deserialised_object = JSON.load(maintain_backwards_compatiblity_with_producer_keys(string))
      from_hash(deserialised_object)
    end

    def self.maintain_backwards_compatiblity_with_producer_keys string
      string.gsub('"producer":', '"provider":').gsub('"producer_state":', '"provider_state":')
    end

    def find_interaction criteria
      interactions = find_interactions criteria
      if interactions.size == 0
        raise "Could not find interaction matching #{criteria} in pact file between #{consumer.name} and #{provider.name}."
      elsif interactions.size > 1
        raise "Found more than 1 interaction matching #{criteria} in pact file between #{consumer.name} and #{provider.name}."
      end
      interactions.first
    end

    def find_interactions criteria
      interactions.select{ | interaction| interaction.matches_criteria?(criteria)}
    end

    def each
      interactions.each do | interaction |
        yield interaction
      end
    end

    def pact_file_name
      "#{filenamify(consumer.name)}-#{filenamify(provider.name)}.json"
    end

      def pactfile_path
        raise 'You must first specify a consumer and service name' unless (consumer && consumer.name && provider && provider.name)
        @pactfile_path ||= File.join(Pact.configuration.pact_dir, pact_file_name)
      end

      def update_pactfile
        logger.debug "Updating pact file for #{provider.name} at #{pactfile_path}"
        check_for_active_support_json
        File.open(pactfile_path, 'w') do |f|
          f.write JSON.pretty_generate(self)
        end
      end

    private

      def filenamify name
        name.downcase.gsub(/\s/, '_')
      end
  end
end