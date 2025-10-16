# frozen_string_literal: true

require "pact/v2/rspec"

RSpec.describe 'Test matt plugin sync message loading', :pact_v2 do
  has_plugin_async_message_pact_between "matttcpconsumer", "matttcpprovider"

  let(:matt_message) do
    {
      "response" => { "body" => "tcpworld" }
    }
  end

  let(:interaction) do
    new_interaction
      .given("the world exists")
      .with_plugin("matt", "0.1.1")
      .with_content_type("application/matt")
      .with_transport("matt")
      .with_contents(matt_message)
  end

  it "executes the matt plugin pact test without errors" do
    interaction.execute do |transport|
      # Here you would call your matt TCP service using the transport info.
      # For demonstration, we'll just check the response body.
      # Replace the following with actual TCP call if needed.
      response = matt_message["response"]["body"]
      expect(response).to eq("tcpworld")
    end
  end
end
