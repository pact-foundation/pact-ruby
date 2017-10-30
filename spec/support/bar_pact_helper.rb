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

			honours_pact_with 'Foo' do
				pact_uri './spec/support/foo-bar.json'
			end
		end
	end
end
