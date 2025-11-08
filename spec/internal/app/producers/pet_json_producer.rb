# frozen_string_literal: true

class PetJsonProducer < Sbmt::KafkaProducer::BaseProducer
  option :topic, default: -> { "json-topic" }
  option :uuid, default: -> { SecureRandom.uuid }

  def call(pet_id)
    pet = {
      id: pet_id,
      tags: %w[tag1 tag2],
      colors:
        {
          red: {
            description: "red color",
            link: "http://some-pet-resource.com/red",
            relatesTo: ["green", "blue"],
            title: "Red"
          },
          green: {
            description: "green color",
            link: "http://some-pet-resource.com/red",
            relatesTo: ["red", "blue"],
            title: "Green"
          },
          blue: {
            description: "blue color",
            link: "http://some-pet-resource.com/blue",
            relatesTo: ["green", "red"],
            title: "Blue"
          }
        }

    }
    sync_publish(pet, headers: { "identity-key" => uuid })
  end
end
