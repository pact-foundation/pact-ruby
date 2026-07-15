# frozen_string_literal: true

require 'pact/rspec'

RSpec.describe 'PactConsumers::MattPlugin', :pact do
  mixed_pact_provider 'myprovider', opts: {
    provider_setup_port: 9009,
    http: {
      http_port: 3000,
      log_level: :info,
      pact_dir: File.expand_path('../../pacts', __dir__)
    },
    async: {
      pact_dir: File.expand_path('../../pacts', __dir__)
    }
  }

  around do |example|
    previous_description_filter = ENV['PACT_DESCRIPTION']
    ENV['PACT_DESCRIPTION'] = 'an HTTP request to /matt'
    example.run
  ensure
    ENV['PACT_DESCRIPTION'] = previous_description_filter
  end

  handle_message 'a MATT message' do |_provider_state|
    body = 'MATTtcpworldMATT'
    metadata = { content_type: 'application/matt' }
    [body, metadata]
  end
end