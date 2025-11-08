# frozen_string_literal: true

class PetProtoProducer < Sbmt::KafkaProducer::BaseProducer
  option :topic, default: -> { "proto-topic" }
  option :uuid, default: -> { SecureRandom.uuid }
  option :serializer, default: -> { PetStore::Grpc::PetStore::V1::Pet }

  def call(pet_id)
    message = serializer.new(
      id: pet_id,
      name: "some pet",
      tags: %w[tag1 tag2],
      colors: [
        PetStore::Grpc::PetStore::V1::PetColor.new(
          description: "red color",
          link: "http://some-pet-resource.com/red",
          relates_to: ["green", "blue"],
          color: "RED"
        ),
        PetStore::Grpc::PetStore::V1::PetColor.new(
          description: "green color",
          link: "http://some-pet-resource.com/green",
          relates_to: ["red", "blue"],
          color: "GREEN"
        )
      ]
    )
    sync_publish(serializer.encode(message), headers: { "identity-key" => uuid })
  end
end
