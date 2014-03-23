require 'spec_helper'
require 'pact/tasks/task_helper'

module Pact
  describe TaskHelper do
    include TaskHelper

    let(:env_description) { "pact description set in ENV"}
    let(:env_provider_state) { "provider state set in ENV"}
    let(:env_criteria){ {:description=>/#{env_description}/, :provider_state=>/#{env_provider_state}/} }
    let(:default_description) { "default description"}
    let(:default_provider_state) { "default provider state"}

    shared_context "PACT_DESCRIPTION is defined" do
      before do
        ENV.stub(:[])
        ENV.stub(:[]).with("PACT_DESCRIPTION").and_return(env_description)
      end
    end

    shared_context 'PACT_PROVIDER_STATE is defined' do
      before do
        ENV.stub(:[])
        ENV.stub(:[]).with("PACT_PROVIDER_STATE").and_return(env_provider_state)
      end
    end

    shared_context 'default description is defined' do
      let(:default_description) { "default description"}
    end

    let(:defaults) { {:description => default_description, :provider_state => default_provider_state} }

    describe "spec_criteria" do

      context "when ENV variables are defined" do
        before do
          ENV.stub(:fetch).with("PACT_DESCRIPTION", anything).and_return(env_description)
          ENV.stub(:fetch).with("PACT_PROVIDER_STATE", anything).and_return(env_provider_state)
        end

        context "when defaults are not passed in" do
          it "returns the env vars as regexes" do
            expect(spec_criteria).to eq(env_criteria)
          end
        end

        context "when defaults are passed in" do
          it "returns the env vars as regexes" do
            expect(spec_criteria(defaults)).to eq(env_criteria)
          end
        end
      end

      context "when ENV variables are not defined" do
        context "when defaults are passed in" do
          it "returns the defaults as regexes" do
            expect(spec_criteria(defaults)).to eq({:description=>/#{default_description}/, :provider_state=>/#{default_provider_state}/})
          end
        end
        context "when defaults are not passed in" do
          it "returns an empty hash" do
            expect(spec_criteria).to eq({})
          end
        end
      end

      context "when provider state is an empty string" do
        before do
          ENV.stub(:fetch).with(anything, anything).and_return(nil)
          ENV.stub(:fetch).with("PACT_PROVIDER_STATE", anything).and_return('')
        end

        it "returns a nil provider state so that it matches a nil provider state on the interaction" do
          expect(spec_criteria[:provider_state]).to be_nil
        end
      end
    end
  end
end
