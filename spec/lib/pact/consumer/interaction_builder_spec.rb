require 'spec_helper'
require 'pact/consumer/interaction_builder'

module Pact
  module Consumer
    describe InteractionBuilder do

      subject { InteractionBuilder.new {|interaction|} }
      let(:interaction) { double('Interaction').as_null_object}

      before do
        expect(Interaction).to receive(:new).and_return(interaction)
      end

      describe "given" do
        context "with a string provider state" do
          it "sets the provider_state on the interaction" do
            expect(interaction).to receive(:provider_state=).with('blah')
            subject.given('blah')
          end
        end

        context "with a symbol provider state" do
          it "sets the provider_state on the interaction as a string" do
            expect(interaction).to receive(:provider_state=).with('some_symbol')
            subject.given(:some_symbol)
          end
        end

        it "returns itself" do
          expect(subject.given(nil)).to be(subject)
        end
      end

      describe "upon_receiving" do
        it "sets the description on the interaction" do
          expect(interaction).to receive(:description=).with('blah')
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
          expect(Pact::Request::Expected).to receive(:from_hash).with(request).and_return(expected_request)
          expect(interaction).to receive(:request=).with(expected_request)
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

        subject { InteractionBuilder.new {|interaction| provider.callback interaction } }

        it "sets the response on the interaction" do
          expect(interaction).to receive(:response=).with(response)
          subject.will_respond_with(response)
        end

        it "returns itself" do
          expect(subject.given(nil)).to be(subject)
        end

        it "invokes the 'on_interaction_fully_defined' callback" do
          expect(provider).to receive(:callback).with(interaction)
          subject.will_respond_with response
        end
      end
    end
  end
end
