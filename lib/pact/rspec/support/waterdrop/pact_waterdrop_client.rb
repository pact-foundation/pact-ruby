# frozen_string_literal: true

class PactWaterdropClient
  attr_reader :message

  Report = Struct.new(:partition, :offset, :topic_name, keyword_init: true)

  def produce_async(message)
    @message = message
  end

  def produce_sync(message)
    @message = message
    Report.new(partition: 0, offset: 0, topic_name: message[:topic])
  end

  def to_pact(content_type: nil)
    payload = message[:payload]
    metadata = {
      key: message[:key],
      topic: message[:topic],
      content_type: content_type
    }.merge(message[:headers] || {})

    [payload, metadata]
  end
end
