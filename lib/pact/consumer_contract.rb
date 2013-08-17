require 'pact/consumer/service_consumer'
require 'pact/consumer/service_producer'
require 'pact/consumer/interaction'
require 'date'

module Pact
	class ConsumerContract

		attr_accessor :interactions
		attr_accessor :consumer
		attr_accessor :producer

		def initialize(opts = {})
			@interactions = opts[:interactions] || []
			@consumer = opts[:consumer]
			@producer = opts[:producer]
		end

		def as_json(options = {})
			{
				producer: @producer.as_json,
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
		  	:consumer => Pact::Consumer::ServiceConsumer.from_hash(obj['consumer']),
		  	:producer => Pact::Consumer::ServiceProducer.from_hash(obj['producer'] || {})
		  })
		end

		def self.from_json string
			deserialised_object = JSON.load(string)
			from_hash(deserialised_object)
		end

		def find_interaction criteria
			interactions = find_interactions criteria
			if interactions.size == 0
				raise "Could not find interaction matching #{criteria} in pact file between #{consumer.name} and #{producer.name}."
			elsif interactions.size > 1
				raise "Found more than 1 interaction matching #{criteria} in pact file between #{consumer.name} and #{producer.name}."
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

		def match_criteria? interaction, criteria
			criteria.each do | key, value |
				unless match_criterion interaction[key.to_s], value
					return false
				end
			end
			true
		end

		def match_criterion target, criterion
			target == criterion || (criterion.is_a?(Regexp) && criterion.match(target))
		end

		def pact_file_name
			"#{filenamify(consumer.name)}-#{filenamify(producer.name)}.json"
		end

		private

      def filenamify name
        name.downcase.gsub(/\s/, '_')
      end		
	end
end