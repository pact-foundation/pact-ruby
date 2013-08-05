require 'pact/consumer/service_consumer'

module Pact
	class ConsumerContract

		attr_reader :interactions
		attr_reader :consumer

		def initialize(opts)
			@interactions = opts[:interactions]
			@consumer = opts[:consumer]
		end

		def as_json(options = {})
			{
				consumer: @consumer.as_json,
				interactions: @interactions.collect(&:as_json)
			}
		end

		def to_json(options = {})
			as_json(options).to_json(options)
		end

		def self.json_create(obj)
		  new({:interactions => obj['interactions'], :consumer => Pact::Consumer::ServiceConsumer.json_create(obj['consumer'] || {})})
		end

		def self.from_json string
			deserialised_object = JSON.load(string)
			json_create(deserialised_object)
			# if deserialised_object.is_a? Hash
			# 	ConsumerContract.new(interactions: deserialised_object['interactions'])
			# elsif deserialised_object.is_a? Array #For backwards compatiblity
			# 	ConsumerContract.new(interactions: deserialised_object)
			# else
			# 	raise "Don't know how to handle deserialized object #{deserialised_object}"
			# end
		end

		def each
			interactions.each do | interaction |
				yield interaction
			end
		end
	end
end