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
        let(:command) { "SPEC_OPTS='' #{ruby_path} -S pact verify --pact-helper #{default_pact_helper_path}" }
        it "executes the command" do
          expect(TaskHelper).to receive(:execute_cmd).with(command)
          TaskHelper.execute_pact_verify
        end
      end

      context "with a pact URI" do
        let(:command) { "SPEC_OPTS='' #{ruby_path} -S pact verify --pact-helper #{default_pact_helper_path} --pact-uri #{pact_uri}" }
        it "executes the command" do
          expect(TaskHelper).to receive(:execute_cmd).with(command)
          TaskHelper.execute_pact_verify(pact_uri)
        end
      end

      context "with a pact URI and a pact_helper" do
        let(:custom_pact_helper_path) { '/custom/pact_helper.rb' }
        let(:command) { "SPEC_OPTS='' #{ruby_path} -S pact verify --pact-helper #{custom_pact_helper_path} --pact-uri #{pact_uri}" }
        it "executes the command" do
          expect(TaskHelper).to receive(:execute_cmd).with(command)
          TaskHelper.execute_pact_verify(pact_uri, custom_pact_helper_path)
        end
      end

      context "with a pact_helper with no .rb on the end" do
        let(:custom_pact_helper_path) { '/custom/pact_helper' }
        let(:command) { "SPEC_OPTS='' #{ruby_path} -S pact verify --pact-helper #{custom_pact_helper_path}.rb --pact-uri #{pact_uri}" }
        it "executes the command" do
          expect(TaskHelper).to receive(:execute_cmd).with(command)
          TaskHelper.execute_pact_verify(pact_uri, custom_pact_helper_path)
        end
      end

      context "with a pact URI and a nil pact_helper" do
        let(:command) { "SPEC_OPTS='' #{ruby_path} -S pact verify --pact-helper #{default_pact_helper_path} --pact-uri #{pact_uri}" }
        it "executes the command" do
          expect(TaskHelper).to receive(:execute_cmd).with(command)
          TaskHelper.execute_pact_verify(pact_uri, nil)
        end
      end

      context "with PACT_REPO_USERNAME set" do
        before do
          ENV['PACT_REPO_USERNAME'] = 'pact_username'
        end

        it "includes the -u option in the command" do
          expect(TaskHelper).to receive(:execute_cmd).with(/--pact_repository_username pact_username/)
          TaskHelper.execute_pact_verify(pact_uri, nil, nil)
        end

        after do
          ENV.delete('PACT_REPO_USERNAME')
        end
      end

      context "with PACT_REPO_PASSWORD set" do
        before do
          ENV['PACT_REPO_PASSWORD'] = 'pact_password'
        end

        it "includes the -w option in the command" do
          expect(TaskHelper).to receive(:execute_cmd).with(/--pact_repository_password pact_password/)
          TaskHelper.execute_pact_verify(pact_uri, nil, nil)
        end

        after do
          ENV.delete('PACT_REPO_PASSWORD')
        end
      end

      context "with rspec_opts" do
        it "includes the rspec_opts as SPEC_OPTS in the command" do
          expect(TaskHelper).to receive(:execute_cmd) do | command |
            expect(command).to start_with("SPEC_OPTS=--reporter\\ SomeReporter #{ruby_path}")
          end
          TaskHelper.execute_pact_verify(pact_uri, nil, "--reporter SomeReporter")
        end
      end

      context "with $BACKTRACE=true" do
        before do
          ENV['BACKTRACE'] = 'true'
        end

        it "includes the -b option in the command" do
          expect(TaskHelper).to receive(:execute_cmd).with(/\s\--backtrace\b/)
          TaskHelper.execute_pact_verify(pact_uri, nil, nil)
        end

        after do
          ENV.delete('BACKTRACE')
        end
      end

      context "with PACT_DESCRIPTION set" do
        before do
          ENV['PACT_DESCRIPTION'] = 'some description'
        end

        it "includes the -b option in the command" do
          expect(TaskHelper).to receive(:execute_cmd).with(/--description some\\ description/)
          TaskHelper.execute_pact_verify(pact_uri, nil, nil)
        end

        after do
          ENV.delete('PACT_DESCRIPTION')
        end
      end

      context "with PACT_PROVIDER_STATE set" do
        before do
          ENV['PACT_PROVIDER_STATE'] = 'some state'
        end

        it "includes the -b option in the command" do
          expect(TaskHelper).to receive(:execute_cmd).with(/--provider-state some\\ state/)
          TaskHelper.execute_pact_verify(pact_uri, nil, nil)
        end

        after do
          ENV.delete('PACT_PROVIDER_STATE')
        end
      end

      context "with PACT_PROVIDER_STATE set as an emtpy string" do
        before do
          ENV['PACT_PROVIDER_STATE'] = ''
        end

        it "includes the -b option in the command" do
          expect(TaskHelper).to receive(:execute_cmd).with(/--provider-state ''/)
          TaskHelper.execute_pact_verify(pact_uri, nil, nil)
        end

        after do
          ENV.delete('PACT_PROVIDER_STATE')
        end
      end

    end


  end
end
