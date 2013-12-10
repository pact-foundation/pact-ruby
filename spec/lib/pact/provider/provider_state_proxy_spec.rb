require 'spec_helper'
require 'pact/provider/provider_state_proxy'

module Pact
  module Provider
    describe ProviderStateProxy do

      let(:provider_state_proxy) { ProviderStateProxy.new }

      describe "get" do
        let(:name) { "some state" }
        let(:options) { { :for => 'some consumer'} }
        let(:provider_state) { double("provider_state")}

        subject { provider_state_proxy.get name, options }

        before do
          ProviderStates.stub(:get).and_return(provider_state)
        end
        context "when the provider state exists" do

          it "retrieves the provider state from ProviderState" do
            ProviderStates.should_receive(:get).with(name, options).and_return(provider_state)
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
    end
  end
end