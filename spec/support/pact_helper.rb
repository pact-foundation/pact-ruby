# This is the pact_helper for rake pact:tests
require 'json'
require 'pact/provider/rspec'
require './spec/support/active_support_if_configured'

module Pact
	module Test
		class TestApp
			def call env
				if env['PATH_INFO'] == '/weather'
					[200, {'Content-Type' => 'application/json'}, [{message: WEATHER[:current_state], :array => [{"foo"=> "blah"}]}.to_json]]
				elsif env['PATH_INFO'] == '/sometext'
					[200, {'Content-Type' => 'text/plain'}, ['some text']]
				elsif env['PATH_INFO'] == '/content_type_is_important'
						[200, {'Content-Type' => 'application/json'}, [{message: "A message", note: "This will cause verify to fail if it using the wrong content type differ."}.to_json]]
				else
					raise "unexpected path #{env['PATH_INFO']}!!!"
				end
			end
		end

		Pact.configure do | config |
			config.logger.level = Logger::DEBUG
			config.diff_formatter = :unix
		end

		Pact.service_provider "Some Provider" do
			app { TestApp.new }

			honours_pact_with 'some-test-consumer' do
				pact_uri './spec/support/test_app_pass.json'
			end
		end

		Pact.set_up do
			WEATHER ||= {}
		end

		#one with a top level consumer
		Pact.provider_states_for 'some-test-consumer' do

			provider_state "the weather is sunny" do
				set_up do

					WEATHER[:current_state] = 'sunny'
				end
			end
		end

		#one without a top level consumer
		Pact.provider_state "the weather is cloudy" do
			set_up do
				WEATHER[:current_state] = 'cloudy'
			end
		end
	end
end
