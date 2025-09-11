# frozen_string_literal: true

class PetProtoConsumer < Sbmt::KafkaConsumer::BaseConsumer
  def process_message(message)
    Rails.logger.info "Pet ID: #{message.payload.id}"
  end
end
