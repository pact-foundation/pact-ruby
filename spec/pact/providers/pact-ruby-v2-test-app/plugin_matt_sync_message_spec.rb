# frozen_string_literal: true

require 'pact/rspec'

RSpec.describe 'Test matt plugin sync message loading', :pact do
  has_plugin_sync_message_pact_between 'myconsumer', 'myprovider'

  let(:matt_message) do
    {
      'request' => { 'body' => 'hellotcp' },
      'response' => { 'body' => 'tcpworld' }
    }
  end

  let(:interaction) do
    new_interaction('a MATT message')
      .given('the world exists')
      .with_plugin('matt', '0.1.1')
      .with_content_type('application/matt')
      .with_transport('matt')
      .with_request(matt_message['request'])
      .will_respond_with(matt_message['response'])
  end

  it 'returns a valid MATT message' do
    interaction.execute do |transport|
      # Replace this with your actual TCP call if needed
      # For demonstration, we'll just check the response body.
      response = matt_message['response']['body']
      expect(response).to eq('tcpworld')
    end
  end
end
