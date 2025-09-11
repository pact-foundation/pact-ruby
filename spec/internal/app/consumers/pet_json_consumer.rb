# frozen_string_literal: true

class PetJsonConsumer < Sbmt::KafkaConsumer::BaseConsumer
  def process_message(message)
    pet_id = message.payload["id"]
    Rails.logger.info "Pet ID: #{pet_id}"
  end
end
