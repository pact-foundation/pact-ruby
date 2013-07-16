require 'json'

module Pact

	class TestApp
		def call env
			[200, {}, ['this is a response']]
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

end