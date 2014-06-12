require 'spec_helper'
require 'pact/cli'

module Pact
  describe SpecCriteria do

    describe "#spec_criteria" do

      let(:env_description) { "pact description set in ENV"}
      let(:env_provider_state) { "provider state set in ENV"}
      let(:env_criteria){ {:description=>/#{env_description}/, :provider_state=>/#{env_provider_state}/} }

      let(:defaults) { {:description => default_description, :provider_state => default_provider_state} }

      let(:subject) { Pact::App.new }

      context "when ENV variables are defined" do
        before do
          allow(ENV).to receive(:[])
          allow(ENV).to receive(:[]).with("PACT_DESCRIPTION").and_return(env_description)
          allow(ENV).to receive(:[]).with("PACT_PROVIDER_STATE").and_return(env_provider_state)
        end

        it "returns the env vars as regexes" do
          expect(SpecCriteria.call).to eq(env_criteria)
        end
      end

      context "when ENV variables are not defined" do
        it "returns an empty hash" do
          expect(SpecCriteria.call).to eq({})
        end
      end

      context "when provider state is an empty string" do
        before do
          allow(ENV).to receive(:[]).with(anything).and_return(nil)
          allow(ENV).to receive(:[]).with("PACT_PROVIDER_STATE").and_return('')
        end

        it "returns a nil provider state so that it matches a nil provider state on the interaction" do
          expect(SpecCriteria.call[:provider_state]).to be_nil
        end
      end
    end
  end
end
