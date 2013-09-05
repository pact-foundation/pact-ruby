require './lib/pact/provider/pact_spec_runner'

namespace :pact do

	desc 'Runs pact tests against a sample application, testing failure and success.'
	task :tests do
		silent = true
		puts "Running task pact:tests"
		# Run these specs silently, otherwise expected failures will be written to stdout and look like unexpected failures.

		result = Pact::Provider::PactSpecRunner.run([{ uri: './spec/support/test_app_pass.json' }], silent: silent)
		fail 'Expected pact to pass' unless (result == 0)

		result = Pact::Provider::PactSpecRunner.run([{ uri: './spec/support/test_app_fail.json', support_file: './spec/support/pact_helper.rb' }], silent: silent)
		fail 'Expected pact to fail' if (result == 0)

		puts "Task pact:tests completed succesfully."
	end

end