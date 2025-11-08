require 'pact'
require 'pact/rspec'
require_relative '../../../internal/app/consumers/test_message_consumer'

describe TestMessageConsumer, :pact do
  has_message_pact_between 'Test Message Consumer', 'Test Message Provider'

  subject(:consumer) { TestMessageConsumer.new }

  describe 'Test Message Consumer' do
    # Notice that the expected message payload has fields which are different to that of the actual producer.
    # The TestMessageProducer actually sends a message with an additional 'title' field and a renamed 'surname' field.
    # See app/producers/test_message_producer.rb.

    # before do
    #   # Here we are calling test_message_producer, which is mocking the actual TestMessageProducer defined in app/producers/test_message_producer.rb.
    #   # In pact-message we use mocked providers in consumer side tests. These are defined in a similar way to mocked APIs/service providers in standard HTTP CDCT.
    #   # See spec/support/pact_spec_helper.rb.
    #   let(:expected_payload)
    #   {
    #     "email": match_type_of('jane@example.com'),
    #     "first_name": match_type_of('Jane')
    #     # "last_name": Pact.like("Doe") # uncomment to see failure in provider code
    #   }

    #   let(:interaction) do
    #     new_interaction.given('A customer is created')
    #                          .upon_receiving('a customer created message')
    #                          # .with_metadata()
    #                          # .with_json_contents(match_type_of(expected_payload))
    #                          .with_json_contents(expected_payload)
    #   end
    # end

    # This test is a bit redundant, it's essentially marking our own homework and will always pass.
    # However IRL the consumer would probably be doing something more complex which we could assert on.
    # See spec/pacts/test_message_consumer-test_message_producer.json for the generated contract file.
    # Note that this contract does not match what the producer outputs in app/producers/test_message_producer.rb..
    # If we were to run producer side verification on this contract, it should fail.
    # This failure would indicate a mismatch between the consumers expectations of the message format and what the producer actually sends.

    let(:expected_payload) do
      {
        "email": match_type_of('jane@example.com'),
        "first_name": match_type_of('Jane')
        # "last_name": Pact.like("Doe") # uncomment to see failure in provider code
      }
    end

    let(:interaction) do
      new_interaction.given('A customer is created')
                           .upon_receiving('a customer created message')
                           # .with_metadata()
                           # .with_json_contents(match_type_of(expected_payload))
                           .with_json_contents(expected_payload)
    end

    it 'Successfully consumes the message and creates a pact contract file' do
      interaction.execute do |json_payload, _meta|
        @message = consumer.consume_message(json_payload)
        expect(@message).to eq(json_payload)
      end
    end
  end
end
