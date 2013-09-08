require 'json'
# pact_helper for rake pact:tests

module Pact
	module Test
		class TestApp
			def call env
				if env['PATH_INFO'] == '/weather'
					[200, {'Content-Type' => 'application/json'}, [{message: WEATHER[:current_state]}.to_json]]
				else
					raise "unexpected path #{env['PATH_INFO']}!!!"
				end
			end
		end

		Pact.service_provider "Some Provider" do
			app { TestApp.new }
			honours_pact_with "some-test-consumer", :head do
				uri './spec/support/test_app_pass.json'
			end
			honours_pact_with 'some-test-consumer', :prod do
				uri './spec/support/test_app_fail.json'
			end
			honours_pact_with 'some-test-consumer', :local do
				uri './/blah'
				task :local
			end
			honours_pact_with 'some-test-consumer' do
				uri './spec/support/test_app_pass.json', :ref => :head
				uri './spec/support/test_app_pass.json', :ref => :prod
				uri './spec/support/test_app_pass.json', :ref => :local, :task => :local
			end
		end


		#one with a top level consumer
		Pact.provider_states_for 'some-test-consumer' do
			provider_state "the weather is sunny" do
				set_up do
					WEATHER ||= {}
					WEATHER[:current_state] = 'sunny'
				end
			end
		end

		#one without a top level consumer
		Pact.provider_state "the weather is cloudy" do
			set_up do
				WEATHER ||= {}
				WEATHER[:current_state] = 'cloudy'
			end
		end
	end
end
