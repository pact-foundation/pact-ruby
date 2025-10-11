# frozen_string_literal: true

require 'pact/v2'
require 'pact/v2/rspec'
require_relative '../../internal/app/producers/test_message_producer'

RSpec.describe 'Test Message Provider', :pact_v2 do
  message_pact_provider 'Test Message Producer', opts: {
    pact_dir: File.expand_path('../../pacts', __dir__),
  }

  handle_message 'a customer created message' do |provider_state|
    body = TestMessageProducer.new.publish_message
    metadata = {}
    [body, metadata]
  end
end
