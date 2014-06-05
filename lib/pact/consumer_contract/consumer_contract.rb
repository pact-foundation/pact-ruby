require 'pact/logging'
require 'pact/something_like'
require 'pact/symbolize_keys'
require 'pact/term'
require 'pact/version'
require 'pact/shared/active_support_support'
require 'date'
require 'json/add/regexp'
require 'open-uri'
require_relative 'service_consumer'
require_relative 'service_provider'
require_relative 'interaction'
require_relative 'request'
require_relative 'pact_file'
require_relative 'file_name'



module Pact

  class ConsumerContract

    include SymbolizeKeys
    include Logging
    include FileName
    include ActiveSupportSupport

    attr_accessor :interactions
    attr_accessor :consumer
    attr_accessor :provider

    def initialize(attributes = {})
      @interactions = attributes[:interactions] || []
      @consumer = attributes[:consumer]
      @provider = attributes[:provider]
    end

    def to_hash
      {
        provider: @provider.as_json,
        consumer: @consumer.as_json,
        interactions: @interactions.collect(&:as_json),
        metadata: {
          pactSpecificationVersion: "1.0.0"
        }
      }
    end

    def as_json(options = {})
      fix_all_the_things to_hash
    end

    def to_json(options = {})
      as_json.to_json(options)
    end

    def self.from_hash(hash)
      hash = symbolize_keys(hash)
      new({
        :interactions => hash[:interactions].collect { |hash| Interaction.from_hash(hash)},
        :consumer => ServiceConsumer.from_hash(hash[:consumer]),
        :provider => ServiceProvider.from_hash(hash[:provider])
      })
    end

    def self.from_json string
      deserialised_object = JSON.load(maintain_backwards_compatiblity_with_producer_keys(string))
      from_hash(deserialised_object)
    end

    def self.from_uri uri, options = {}
      from_json(Pact::PactFile.read(uri, options))
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
      file_name consumer.name, provider.name
    end

    def pactfile_path
      raise 'You must first specify a consumer and service name' unless (consumer && consumer.name && provider && provider.name)
      @pactfile_path ||= file_path consumer.name, provider.name
    end

    def update_pactfile
      logger.debug "Updating pact file for #{provider.name} at #{pactfile_path}"
      File.open(pactfile_path, 'w') do |f|
        f.write fix_json_formatting(JSON.pretty_generate(self))
      end
    end
  end
end