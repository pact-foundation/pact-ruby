require 'spec_helper'
require 'pact/tasks/task_helper'
require 'rake/file_utils'

module Pact
  describe TaskHelper do


    describe ".execute_pact_verify" do
      let(:ruby_path) { "/path/to/ruby" }
      let(:pact_uri) { "/pact/uri" }
      let(:default_pact_helper_path) { "/pact/helper/path.rb" }

      before do
        stub_const("FileUtils::RUBY", ruby_path)
        allow(Pact::Provider::PactHelperLocater).to receive(:pact_helper_path).and_return(default_pact_helper_path)
      end

      context "with no pact_helper or pact URI" do
        let(:command) { "#{ruby_path} -S pact verify -h #{default_pact_helper_path}" }
        it "executes the command" do
          expect(TaskHelper).to receive(:execute_command).with(command)
          TaskHelper.execute_pact_verify
        end
      end

      context "with a pact URI" do
        let(:command) { "#{ruby_path} -S pact verify -h #{default_pact_helper_path} -p #{pact_uri}" }
        it "executes the command" do
          expect(TaskHelper).to receive(:execute_command).with(command)
          TaskHelper.execute_pact_verify(pact_uri)
        end
      end

      context "with a pact URI and a pact_helper" do
        let(:custom_pact_helper_path) { '/custom/pact_helper.rb' }
        let(:command) { "#{ruby_path} -S pact verify -h #{custom_pact_helper_path} -p #{pact_uri}" }
        it "executes the command" do
          expect(TaskHelper).to receive(:execute_command).with(command)
          TaskHelper.execute_pact_verify(pact_uri, custom_pact_helper_path)
        end
      end

      context "with a pact_helper with no .rb on the end" do
        let(:custom_pact_helper_path) { '/custom/pact_helper' }
        let(:command) { "#{ruby_path} -S pact verify -h #{custom_pact_helper_path}.rb -p #{pact_uri}" }
        it "executes the command" do
          expect(TaskHelper).to receive(:execute_command).with(command)
          TaskHelper.execute_pact_verify(pact_uri, custom_pact_helper_path)
        end
      end

      context "with a pact URI and a nil pact_helper" do
        let(:command) { "#{ruby_path} -S pact verify -h #{default_pact_helper_path} -p #{pact_uri}" }
        it "executes the command" do
          expect(TaskHelper).to receive(:execute_command).with(command)
          TaskHelper.execute_pact_verify(pact_uri, nil)
        end
      end

    end


  end
end
