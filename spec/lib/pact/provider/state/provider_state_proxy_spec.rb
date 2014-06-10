require 'spec_helper'
require 'pact/provider/state/provider_state_proxy'

module Pact
  module Provider::State
    describe ProviderStateProxy do

      let(:provider_state_proxy) { ProviderStateProxy.new }

      let(:options) { { :for => 'some consumer'} }
      let(:provider_state) { double("provider_state")}

      describe "get" do
        let(:name) { "some state" }

        subject { provider_state_proxy.get name, options }

        before do
          allow(ProviderStates).to receive(:get).and_return(provider_state)
        end

        context "when the provider state exists" do

          it "retrieves the provider state from ProviderState" do
            expect(ProviderStates).to receive(:get).with(name, options).and_return(provider_state)
            subject
          end

          it "returns the state" do
            expect(subject).to eq provider_state
          end

        end

        context "when the state does not exist" do

          let(:provider_state) { nil }
          let(:expected_missing_provider_states) { {"some consumer" => ["some state"]} }

          it "raises an error" do
            expect { subject }.to raise_error /Could not find.*some state.*consumer.*/
          end

          it "records the provider state as missing" do
            subject rescue nil
            expect(provider_state_proxy.missing_provider_states).to eq expected_missing_provider_states
          end

          context "when the same missing provider state is requested" do
            it "ensures the list only contains unique entries" do
              subject rescue nil
              subject rescue nil
              expect(provider_state_proxy.missing_provider_states['some consumer'].size).to eq 1
            end
          end
        end


      end

      describe "get_base" do

        before do
          allow(ProviderStates).to receive(:get_base).and_return(provider_state)
        end

        subject { provider_state_proxy.get_base options }

        it "calls through to ProviderStates" do
          expect(ProviderStates).to receive(:get_base).with(options)
          subject
        end

        it "returns the state" do
          expect(subject).to eq provider_state
        end
      end
    end
  end
end