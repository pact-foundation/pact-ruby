# This is the pact_helper for rake pact:tests
require 'json'
require 'pact/provider/rspec'
require 'ostruct'

module Pact
  module Test
    class ParamsTestApp

      ALLIGATORS = []

      def call env
        [200, {'Content-Type' => 'application/json'}, [ALLIGATORS.first.to_h.to_json]]
      end
    end

    Pact.configure do | config |
      config.reports_dir = 'tmp/spec_reports'
    end

    Pact.service_provider "some-test-provider" do
      app { ParamsTestApp.new }
      app_version '1.2.3'
    end

    Pact.provider_states_for 'some-test-consumer' do
      provider_state "the first alligator exists" do
        set_up do | params |
          ParamsTestApp::ALLIGATORS << OpenStruct.new(name: params.fetch('name'))
        end
      end
    end
  end
end
