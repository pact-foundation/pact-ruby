require 'spec_helper'
require 'pact/verification_task'

module Pact
	describe VerificationTask do
		before :all do
			@support_file = 'some_file.rb'
			@pact_uri = 'http://example.org/pact.json'
			@task_name = 'pact:verify:pact_rake_spec'
			@consumer = 'some-consumer'

			VerificationTask.new(:pact_rake_spec) do | pact |
				pact.uri @pact_uri, support_file: @support_file, consumer: @consumer
			end
		end

		describe '.initialize' do

			it 'creates the tasks' do
				Rake::Task.tasks.should include_task @task_name
			end

		end

		describe 'execute' do

			let(:consumer_contract) { [ uri: @pact_uri, support_file: @support_file] }

			it 'verifies the pacts using PactSpecRunner' do
				Provider::PactSpecRunner.should_receive(:run).with(consumer_contract).and_return(0)
				Rake::Task[@task_name].execute
			end

			context 'when all specs pass' do

				before do
					Provider::PactSpecRunner.stub(:run).and_return(0)
				end

				it 'does not raise an exception' do
					Rake::Task[@task_name].execute
				end
			end

			context 'when one or more specs fail' do

				before do
					Provider::PactSpecRunner.stub(:run).and_return(1)
				end

				it 'raises an exception' do
					expect { Rake::Task[@task_name].execute }.to raise_error RuntimeError
				end

			end
		end
	end
end

RSpec::Matchers.define :include_task do |expected|
	match do |actual|
	  actual.any? { |task| task.name == expected }
	end
end