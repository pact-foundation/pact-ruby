require 'pact/cli/spec_criteria'

module Pact
  module Cli
    describe SpecCriteria do
      describe "#spec_criteria" do

        let(:env_description) { "pact description set in ENV"}
        let(:env_provider_state) { "provider state set in ENV"}
        let(:env_pact_broker_interaction_id) { "interaction id set in ENV" }
        let(:interaction_index) { 2 }
        let(:env_criteria) do
          {
            :description=>/#{env_description}/,
            :provider_state=>/#{env_provider_state}/,
            :_id => env_pact_broker_interaction_id,
            :index => interaction_index
          }
        end

        let(:defaults) { {:description => default_description, :provider_state => default_provider_state} }

        let(:subject) { Pact::App.new }

        context "when options are defined" do
          let(:options) do
            {
              description: env_description,
              provider_state: env_provider_state,
              pact_broker_interaction_id: env_pact_broker_interaction_id,
              interaction_index: interaction_index
            }
          end

          it "returns the env vars as regexes" do
            expect(Pact::Cli::SpecCriteria.call(options)).to eq(env_criteria)
          end
        end

        context "when ENV variables are not defined" do
          let(:options) { {} }

          it "returns an empty hash" do
            expect(Pact::Cli::SpecCriteria.call(options)).to eq({})
          end
        end

        context "when provider state is an empty string" do
          let(:options) { { provider_state: '' } }

          it "returns a nil provider state so that it matches a nil provider state on the interaction" do
            expect(Pact::Cli::SpecCriteria.call(options)[:provider_state]).to be_nil
          end
        end
      end
    end
  end
end
