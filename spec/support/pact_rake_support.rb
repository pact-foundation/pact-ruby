require 'json'

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

		module PactSpecHelper
			def app
			  TestApp.new
			end
		end

		RSpec.configure do |config|
			config.include PactSpecHelper
		end

		#one with a top level consumer
		Pact.with_consumer 'some-test-consumer' do
			producer_state "the weather is sunny" do
				set_up do
					WEATHER ||= {}
					WEATHER[:current_state] = 'sunny'
				end
			end
		end

		#one without a top level consumer
		Pact.producer_state "the weather is cloudy" do
			set_up do
				WEATHER ||= {}
				WEATHER[:current_state] = 'cloudy'
			end
		end
	end
end
