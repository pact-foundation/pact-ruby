require 'spec_helper'
require 'pact/consumer/mock_service/interaction_list'

module Pact::Consumer

  describe InteractionList do
    shared_context "unexpected requests and missed interactions" do
      let(:expected_interaction) { InteractionFactory.create }
      let(:unexpected_request) { RequestFactory.create_actual method: 'put' }
      let(:candidate_interaction) { double("Pact::Interaction") }
      let(:candidate_interactions) { [candidate_interaction] }
      let(:interaction_mismatch) { instance_double("Pact::Consumer::InteractionMismatch", :short_summary => 'blah', :candidate_interactions => candidate_interactions)}
      subject {
        interactionList = InteractionList.new
        interactionList.add expected_interaction
        interactionList.register_unexpected_request unexpected_request
        interactionList.register_interaction_mismatch interaction_mismatch
        interactionList
       }
    end

    shared_context "no unexpected requests or missed interactions exist" do
      let(:expected_interaction) { InteractionFactory.create }
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
          {:missing_interactions=>["GET /path"],
            :unexpected_requests=>["PUT /path?query"],
            :interaction_mismatches => ['blah']}
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
          expect(subject.all_matched?).to be false
        end
      end
      context "when unexpected requests or missed interactions do not exist" do
        include_context "no unexpected requests or missed interactions exist"
        it "returns false" do
          expect(subject.all_matched?).to be true
        end
      end
    end

    describe "missing_interactions_summaries" do
      include_context "unexpected requests and missed interactions"
      it "returns a list of the method and paths for each missing interaction" do
        expect(subject.missing_interactions_summaries).to eq ["GET /path"]
      end
    end
  end
end