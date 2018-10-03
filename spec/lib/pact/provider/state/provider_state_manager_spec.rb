require 'spec_helper'
require 'pact/provider/state/provider_state_manager'

module Pact::Provider::State
  describe ProviderStateManager do

    PROVIDER_STATE_MESSAGES = []

    before do
      PROVIDER_STATE_MESSAGES.clear
      Pact.clear_provider_world

      Pact.set_up do
        PROVIDER_STATE_MESSAGES << :global_base_set_up
      end

      Pact.tear_down do
        PROVIDER_STATE_MESSAGES << :global_base_tear_down
      end

      Pact.provider_states_for "a consumer with provider states" do
        set_up do
          PROVIDER_STATE_MESSAGES << :consumer_base_set_up
        end

        tear_down do
          PROVIDER_STATE_MESSAGES << :consumer_base_tear_down
        end

        provider_state "a custom state" do
          set_up do
            PROVIDER_STATE_MESSAGES << :custom_consumer_state_set_up
          end

          tear_down do
            PROVIDER_STATE_MESSAGES << :custom_consumer_state_tear_down
          end
        end

      end
    end

    let(:params) { { "foo" => "bar" } }
    let(:provider_state_manager) { ProviderStateManager.new("a custom state", params, "a consumer with provider states") }

    describe "set_up_provider_state" do

      subject { provider_state_manager.set_up_provider_state }

      it "sets up the global base state" do
        subject
        expect(PROVIDER_STATE_MESSAGES[0]).to eq :global_base_set_up
      end

      it "sets up the consumer base state" do
        subject
        expect(PROVIDER_STATE_MESSAGES[1]).to eq :consumer_base_set_up
      end

      it "sets up the consumer custom state" do
        subject
        expect(PROVIDER_STATE_MESSAGES[2]).to eq :custom_consumer_state_set_up
      end
    end

    describe "tear_down_provider_state" do

      subject { provider_state_manager.tear_down_provider_state }

      it "tears down the consumer custom state" do
        subject
        expect(PROVIDER_STATE_MESSAGES[0]).to eq :custom_consumer_state_tear_down
      end

      it "tears down the consumer base state" do
        subject
        expect(PROVIDER_STATE_MESSAGES[1]).to eq :consumer_base_tear_down
      end

      it "tears down the global base state" do
        subject
        expect(PROVIDER_STATE_MESSAGES[2]).to eq :global_base_tear_down
      end
    end
  end
end
