require 'spec_helper'
require 'pact/tasks/verification_task'

module Pact
  describe VerificationTask do
    before :all do
      @pact_helper = '/custom/path/pact_helper  .rb'
      @pact_uri = 'http://example.org/pact.json'
      @task_name = 'pact:verify:pact_rake_spec'
      @task_name_with_explict_pact_helper = 'pact:verify:pact_rake_spec_with_explict_pact_helper'
      @consumer = 'some-consumer'
      @criteria = {:description => /wiffle/}

      VerificationTask.new(:pact_rake_spec_with_explict_pact_helper) do | pact |
        pact.uri @pact_uri, pact_helper: @pact_helper
      end

      VerificationTask.new(:pact_rake_spec) do | pact |
        pact.uri @pact_uri
      end
    end

    before do
      allow(Pact::TaskHelper).to receive(:execute_pact_verify).and_return(0)
    end

    let(:exit_code) {0}


    describe '.initialize' do
      context 'with an explict pact_helper' do
        it 'creates the tasks' do
          expect(Rake::Task.tasks).to include_task @task_name
        end
      end
      context 'with no explict pact_helper' do
        it 'creates the tasks' do
          expect(Rake::Task.tasks).to include_task @task_name_with_explict_pact_helper
        end
      end
    end

    describe 'execute' do

      context "with no explicit pact_helper" do
        it 'verifies the pacts using the TaskHelper' do
          expect(Pact::TaskHelper).to receive(:execute_pact_verify).with(@pact_uri, nil, nil)
          Rake::Task[@task_name].execute
        end
      end

      context "with an explict pact_helper" do
        let(:verification_config) { [ uri: @pact_uri, pact_helper: @pact_helper] }
        it 'verifies the pacts using the TaskHelper' do
          expect(Pact::TaskHelper).to receive(:execute_pact_verify).with(@pact_uri, @pact_helper, nil)
          Rake::Task[@task_name_with_explict_pact_helper].execute
        end
      end

      context 'when all specs pass' do

        it 'does not raise an exception' do
          Rake::Task[@task_name].execute
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
