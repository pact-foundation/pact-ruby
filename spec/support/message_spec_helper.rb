require 'pact/message'

# Example data store

class DataStore
  def self.greeting_recipient= greeting_recipient
    @greeting_recipient = greeting_recipient
  end

  def self.greeting_recipient
    @greeting_recipient
  end
end

# Example message producer

class BarProvider
  def create_message
    {
      text: "Hello #{DataStore.greeting_recipient}"
    }
  end
end

# Provider states

Pact.provider_states_for "Foo" do
  provider_state "a world exists" do
    set_up do
      DataStore.greeting_recipient = "world"
    end
  end
end

CONFIG = {
  "a message" => lambda { BarProvider.new.create_message }
}

Pact.message_provider "Bar" do
  builder { |description| CONFIG[description].call }
end
