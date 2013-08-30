require 'pact/consumer_contract/service_consumer'
require 'pact/consumer_contract/service_provider'
require 'pact/consumer/interaction'
require 'pact/logging'
require 'pact/json_warning'
require 'date'
require 'pact/version'

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
        :interactions => obj['interactions'].collect { |hash| Pact::Consumer::Interaction.from_hash(hash)},
        :consumer => Pact::ServiceConsumer.from_hash(obj['consumer']),
        :provider => Pact::ServiceProvider.from_hash(obj['provider'] || {})
      })
    end

    def self.from_json string
      deserialised_object = JSON.load(string)
      from_hash(deserialised_object)
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
      interactions.select{ | interaction| match_criteria? interaction, criteria}
    end

    def each
      interactions.each do | interaction |
        yield interaction
      end
    end

    # Move this to interaction
    def match_criteria? interaction, criteria
      criteria.each do | key, value |
        unless match_criterion interaction.send(key.to_s), value
          return false
        end
      end
      true
    end

    def match_criterion target, criterion
      target == criterion || (criterion.is_a?(Regexp) && criterion.match(target))
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