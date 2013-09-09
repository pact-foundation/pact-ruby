
namespace :pact do

	desc 'Runs pact tests against a sample application, testing failure and success.'
	task :tests do

		require 'pact/provider/pact_spec_runner'
		require 'open3'

		silent = true
		puts "Running task pact:tests"
		# Run these specs silently, otherwise expected failures will be written to stdout and look like unexpected failures.

		result = Pact::Provider::PactSpecRunner.new([{ uri: './spec/support/test_app_pass.json' }], silent: silent).run
		fail 'Expected pact to pass' unless (result == 0)

		result = Pact::Provider::PactSpecRunner.new([{ uri: './spec/support/test_app_fail.json', support_file: './spec/support/pact_helper.rb' }], silent: silent).run
		fail 'Expected pact to fail' if (result == 0)

		expect_to_pass "bundle exec rake pact:verify"
		expect_to_pass "bundle exec rake pact:verify:at[./spec/support/test_app_pass.json]"
		expect_to_fail "bundle exec rake pact:verify:at[./spec/support/test_app_fail.json]"

		puts "Task pact:tests completed succesfully."
	end

	def expect_to_fail command
		success = execute_command command
		fail "Expected '#{command}' to fail" if success
	end

	def expect_to_pass command
		success = execute_command command
		fail "Expected '#{command}' to pass" unless success
	end

	def execute_command command
		result = nil
		Open3.popen3(command) {|stdin, stdout, stderr, wait_thr|
		  result = wait_thr.value
		}
		result.success?
	end

end