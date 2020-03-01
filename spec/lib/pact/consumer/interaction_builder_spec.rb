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
        let(:provider) { double(callback: nil) }
        let(:pact_response) { instance_double('Pact::Response') }

        before do
          allow(Pact::Response).to receive(:new).and_return(pact_response)
        end

        subject { InteractionBuilder.new {|interaction| provider.callback(interaction) } }

        it "creates a Pact::Response object from the given hash" do
          expect(Pact::Response).to receive(:new).with(response)
          subject.will_respond_with(response)
        end

        it "sets the Pact::Response object on the interaction" do
          expect(interaction).to receive(:response=).with(pact_response)
          subject.will_respond_with(response)
        end

        it "returns itself" do
          expect(subject.given(nil)).to be(subject)
        end

        it "invokes the 'on_interaction_fully_defined' callback" do
          subject.will_respond_with response
        end
      end

      describe "without_writing_to_pact" do
        it "sets the write_to_pact key to false on metadata" do
          mock_metadata = {}
          expect(interaction).to receive(:metadata).and_return(nil, mock_metadata)
          
          subject.without_writing_to_pact

          expect(mock_metadata).to eq({ write_to_pact: false })
        end

        it "returns itself" do
          expect(subject.without_writing_to_pact).to be(subject)
        end
      end
    end
  end
end
