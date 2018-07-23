require 'json'
require 'pact/provider/rspec'

module Pact
  module Test
    class BarApp
      def call env
        [200, {'Content-Type' => 'application/json'}, [{"status" => "5"},{"status" => "6"}].to_json]
      end
    end

    Pact.configure do | config |
      config.logger.level = Logger::DEBUG
    end

    Pact.service_provider "Bar" do
      app { BarApp.new }
      app_version '1.2.3'
      app_version_tags ['master']
      publish_verification_results true

      honours_pacts_from_pact_broker do
        pact_broker_base_url "http://localhost:9292"
        consumer_version_tags ["prod"]
      end

      honours_pact_with 'Foo' do
        pact_uri './spec/pacts/foo-bar.json'
      end
    end
  end
end
