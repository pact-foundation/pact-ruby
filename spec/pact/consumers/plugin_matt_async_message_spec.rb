# frozen_string_literal: true

require 'pact/rspec'

RSpec.describe 'PactConsumers::MattPluginAsync', :pact do
  message_pact_provider 'pact-ruby-test-app-plugin-async-provider', opts: {
    provider_setup_port: 9009,
    pact_dir: File.expand_path('../../pacts', __dir__)
  }

  before do
    skip 'Pending: verifier harness does not yet support matt transport async provider verification end-to-end'
  end

  handle_message '' do |_provider_state|
    body = '{"contents":{"response":{"body":"tcpworld"}}}'
    metadata = { content_type: 'application/matt' }
    [body, metadata]
  end
end
