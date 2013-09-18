require 'spec_helper'
require 'pact/consumer/mock_service/interaction_list'

module Pact::Consumer

  describe InteractionList do
    shared_context "unexpected requests and missed interactions" do
      let(:expected_interaction) { InteractionFactory.create }
      let(:unexpected_request) { RequestFactory.create_actual }
      subject {
        interactionList = InteractionList.new
        interactionList.add expected_interaction
        interactionList.register_unexpected_request unexpected_request
        interactionList
       }
    end

    shared_context "no unexpected requests or missed interactions exist" do
      let(:expected_interaction) { InteractionFactory.create }
      let(:unexpected_request) { RequestFactory.create_actual }
      subject {
        interactionList = InteractionList.new
        interactionList.add expected_interaction
        interactionList.register_matched expected_interaction
        interactionList
       }
    end

    describe "interaction_diffs" do
      context "when unexpected requests and missed interactions exist" do
        include_context "unexpected requests and missed interactions"
        let(:expected_diff) {
          {:missing_interactions=>[expected_interaction.as_json], :unexpected_requests=>[unexpected_request.as_json]}
        }
        it "returns the unexpected requests and missed interactions" do
          expect(subject.interaction_diffs).to eq expected_diff
        end
      end

      context "when no unexpected requests or missed interactions exist" do
        include_context "no unexpected requests or missed interactions exist"
        let(:expected_diff) {
          {}
        }
        it "returns an empty hash" do
          expect(subject.interaction_diffs).to eq expected_diff
        end
      end
    end

    describe "all_matched?" do
      context "when unexpected requests or missed interactions exist" do
        include_context "unexpected requests and missed interactions"
        it "returns false" do
          expect(subject.all_matched?).to be_false
        end
      end
      context "when unexpected requests or missed interactions do not exist" do
        include_context "no unexpected requests or missed interactions exist"
        it "returns false" do
          expect(subject.all_matched?).to be_true
        end
      end
    end
  end
end