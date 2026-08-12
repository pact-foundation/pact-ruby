# frozen_string_literal: true

require 'pact/rspec'

RSpec.describe 'PactConsumers::Http', :pact do
  mixed_pact_provider 'pact-ruby-test-app-provider', opts: {
    provider_setup_port: 9009,
    http: {
      http_port: 3000,
      log_level: :info,
      pact_dir: File.expand_path('../../pacts', __dir__)
    },
    grpc: {
      grpc_port: 3009
    }
  }
end
