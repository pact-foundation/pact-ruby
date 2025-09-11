# frozen_string_literal: true

require "pact/v2/rspec"

RSpec.describe "Pact::V2::Providers::Test::Kafka", :pact_v2 do
  has_message_pact_between "pact-ruby-v2-test-app", "pact-ruby-v2-test-app"

  let(:karafka_message) { Struct.new(:payload, keyword_init: true) }

  let(:interaction) do
    new_interaction
      .given("pet exists", pet_id: 1)
      .with_headers(
        "identity-key" => match_any_string("some-key")
      )
      .with_metadata(
        topic: match_regex(/.+/, "some-topic"),
        key: match_any_string("key")
      )
  end

  context "with json message payload" do
    let(:consumer) { PetJsonConsumer.consumer_klass }
    let(:interaction) do
      super()
        .upon_receiving("pet message as json")
        .with_json_contents(
          id: match_any_integer(1),
          tags: match_each_regex(/\w+/, %w[tagX tagY]),
          colors: match_each_kv(
            {
              "red" => {
                description: match_any_string("description"),
                link: match_any_string("http://some-site.ru"),
                relatesTo: match_each_regex(/(red|green|blue)/, %w[blue]),
                title: match_any_string("title")
              }
            },
            match_regex(/(red|green|blue)/, "red")
          )
        )
    end

    it "executes the pact test without errors" do
      interaction.execute do |json_payload, meta|
        message = karafka_message.new(payload: json_payload)

        expect(Rails.logger).to receive(:info)
        expect(meta).to eq(
          {
            "contentType" => "application/json",
            "headers" => {
              "identity-key" => "some-key"
            },
            "key" => "key",
            "topic" => "some-topic"
          }
        )

        consumer.new.process_message(message)
      end
    end
  end

  context "with proto message payload" do
    let(:consumer) { PetProtoConsumer.consumer_klass }
    let(:interaction) do
      super()
        .upon_receiving("pet message as proto")
        .with_proto_class("spec/internal/deps/services/pet_store/grpc/pet_store.proto", "Pet")
        .with_proto_contents(
          id: match_any_integer(1),
          name: match_any_string("some pet"),
          tags: match_each_regex(/\w+/, "tagX"),
          colors: match_each(
            {
              description: match_any_string("description"),
              link: match_any_string("http://some-site.ru"),
              relates_to: match_each_regex(/(red|green|blue)/, "blue"),
              color: match_regex(/(RED|GREEN|BLUE)/, "RED")
            }
          )
        )
    end

    it "executes the pact test without errors" do
      interaction.execute do |proto_payload, meta|
        deserialized = PetStore::Grpc::PetStore::V1::Pet.decode(proto_payload)
        message = karafka_message.new(payload: deserialized)

        expect(Rails.logger).to receive(:info)
        expect(meta).to eq(
          {
            "contentType" => "application/protobuf;message=.pet_store.v1.Pet",
            "headers" => {
              "identity-key" => "some-key"
            },
            "key" => "key",
            "topic" => "some-topic"
          }
        )

        consumer.new.process_message(message)
      end
    end
  end
end
