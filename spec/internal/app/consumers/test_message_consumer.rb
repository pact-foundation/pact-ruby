class TestMessageConsumer

  def consume_message(message)
    puts "Message consumed"
    puts message.to_json
    message
  end
  
  end