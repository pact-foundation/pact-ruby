require 'pact/consumer/service_consumer'
require 'pact/consumer/service_producer'

module Pact
	class ConsumerContract

		attr_reader :interactions
		attr_reader :consumer
		attr_reader :producer

		def initialize(opts)
			@interactions = opts[:interactions]
			@consumer = opts[:consumer]
			@producer = opts[:producer]
		end

		def as_json(options = {})
			{
				producer: @producer.as_json,
				consumer: @consumer.as_json,
				interactions: @interactions.collect(&:as_json)
			}
		end

		def to_json(options = {})
			as_json(options).to_json(options)
		end

		def self.json_create(obj)
		  new({
		  	:interactions => obj['interactions'],
		  	:consumer => Pact::Consumer::ServiceConsumer.json_create(obj['consumer']),
		  	:producer => Pact::Consumer::ServiceProducer.json_create(obj['producer'] || {})
		  })
		end

		def self.from_json string
			deserialised_object = JSON.load(string)
			json_create(deserialised_object)
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
	end
end