# frozen_string_literal: true

require_relative "waterdrop/pact_waterdrop_client"

module PactMessageHelpers
  module ProviderHelpers
    def with_pact_producer
      client = PactWaterdropClient.new
      yield(client)
      client.to_pact
    end

    def produce_outbox_item(item)
      raise "Please require sbmt/kafka_producer to use helper" unless defined?(::Sbmt::KafkaProducer)

      with_pact_producer do |client|
        Sbmt::KafkaProducer::OutboxProducer.new(
          client: client, topic: item.transports.first.topic
        ).call(item, item.payload)
      end
    end
  end

  module ConsumerHelpers
    def outbox_headers
      raise "Please require sbmt/outbox to use helper" unless defined?(::Sbmt::Outbox)

      {
        Sbmt::Outbox::OutboxItem::OUTBOX_HEADER_NAME => match_regex(/(.+?_)*outbox_item/, "order_outbox_item"),
        Sbmt::Outbox::OutboxItem::IDEMPOTENCY_HEADER_NAME => match_uuid,
        Sbmt::Outbox::OutboxItem::SEQUENCE_HEADER_NAME => match_regex(/\d+/, "68"),
        Sbmt::Outbox::OutboxItem::EVENT_TIME_HEADER_NAME => match_iso8601,
        Sbmt::Outbox::OutboxItem::DISPATCH_TIME_HEADER_NAME => match_iso8601
      }
    end
  end
end

RSpec.configure do |config|
  config.extend PactMessageHelpers::ProviderHelpers, pact_entity: :provider
  config.include PactMessageHelpers::ConsumerHelpers, pact_entity: :consumer
end
