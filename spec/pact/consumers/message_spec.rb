# frozen_string_literal: true

require 'pact'
require 'pact/rspec'
require_relative '../../internal/app/producers/test_message_producer'

RSpec.describe 'Test Message Provider', :pact do
  message_pact_provider 'Test Message Provider', opts: {
    provider_setup_port: 9009,
    pact_dir: File.expand_path('../../pacts', __dir__)
  }

  handle_message 'a customer created message' do |_provider_state|
    body = TestMessageProducer.new.publish_message
    metadata = {}
    [body, metadata]
  end
end
