require 'spec_helper'
require 'pact/provider/provider_state_proxy'

module Pact
  module Provider
    describe ProviderStateProxy do

      describe "get" do
        let(:name) { "some state" }
        let(:options) { { :for => 'some consumer'} }
        let(:provider_state) { double("provider_state")}
        subject { ProviderStateProxy.new.get name, options }

        before do
          ProviderState.stub(:get).and_return(provider_state)
        end
        context "when the provider state exists" do

          it "retrieves the provider state from ProviderState" do
            ProviderState.should_receive(:get).with(name, options).and_return(provider_state)
            subject
          end

          it "returns the state" do
            expect(subject).to eq provider_state
          end

        end

        context "when the state does not exist" do

          let(:provider_state) { nil }
          context "when a consumer is specified" do
            it "raises an error" do
              expect { subject }.to raise_error /Could not find.*some state.*consumer.*/
            end
          end
          context "when a consumer is not specified" do

            let(:options) { {} }
            it "raises an error" do
              expect { subject }.to raise_error /Could not find.*some state*/
            end
          end
        end
      end
    end
  end
end