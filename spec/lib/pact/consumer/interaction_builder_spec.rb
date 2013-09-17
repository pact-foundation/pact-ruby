require 'spec_helper'
require 'pact/consumer/interaction_builder'

module Pact
  module Consumer
    describe InteractionBuilder do

      subject { InteractionBuilder.new }
      let(:interaction) { double('Interaction').as_null_object}

      before do
        Interaction.should_receive(:new).and_return(interaction)
      end

      describe "given" do
        context "with a string provider state" do
          it "sets the provider_state on the interaction" do
            interaction.should_receive(:provider_state=).with('blah')
            subject.given('blah')
          end
        end

        context "with a symbol provider state" do
          it "sets the provider_state on the interaction as a string" do
            interaction.should_receive(:provider_state=).with('some_symbol')
            subject.given(:some_symbol)
          end
        end

        it "returns itself" do
          expect(subject.given(nil)).to be(subject)
        end
      end

      describe "upon_receiving" do
        it "sets the description on the interaction" do
          interaction.should_receive(:description=).with('blah')
          subject.upon_receiving('blah')
        end

        it "returns itself" do
          expect(subject.given(nil)).to be(subject)
        end
      end

      describe "with" do

        let(:request) { {a: 'request'} }
        let(:expected_request) { {an: 'expected_request'} }

        it "sets the request on the interaction as a instance of Request::Expected" do
          Pact::Request::Expected.should_receive(:from_hash).with(request).and_return(expected_request)
          interaction.should_receive(:request=).with(expected_request)
          subject.with(request)
        end

        it "returns itself" do
          expect(subject.given(nil)).to be(subject)
        end
      end 

      describe "will_respond_with" do
        let(:response) { {a: 'response'} }

        let(:provider) do
          double(callback: nil)
        end

        before do
          subject.on_interaction_fully_defined do | interaction |
            provider.callback interaction
          end
        end

        it "sets the response on the interaction" do
          interaction.should_receive(:response=).with(response)
          subject.will_respond_with(response)
        end

        it "returns itself" do
          expect(subject.given(nil)).to be(subject)
        end

        it "invokes the 'on_interaction_fully_defined' callback" do
          provider.should_receive(:callback).with(interaction)
          subject.will_respond_with response
        end          
      end
    end
  end
end
