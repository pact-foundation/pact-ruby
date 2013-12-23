require 'spec_helper'
require 'pact/consumer/mock_service/interaction_mismatch'

module Pact
  module Consumer
    describe InteractionMismatch do
      let(:actual_request) { instance_double('Pact::Consumer::Request::Actual', :method_and_path => 'GET /path') }
      let(:expected_request_1) { instance_double('Pact::Request::Expected') }
      let(:expected_request_2) { instance_double('Pact::Request::Expected') }
      let(:candidate_1) { instance_double('Pact::Interaction', request: expected_request_1) }
      let(:candidate_2) { instance_double('Pact::Interaction', request: expected_request_2) }
      let(:candidate_interactions) { [candidate_1, candidate_2] }
      subject { InteractionMismatch.new(candidate_interactions, actual_request) }
      let(:diff_1) { {body: nil} }
      let(:diff_2) { {} }

      before do
        expected_request_1.stub(:difference).with(actual_request).and_return(diff_1)
        expected_request_2.stub(:difference).with(actual_request).and_return(diff_2)
      end

      describe "short_summary" do
        it "includes the method and path" do
          expect(subject.short_summary).to match /GET \/path \(.*\)/
        end
        context "when the body does not match" do
          let(:diff_1) { {body: nil} }

          it "returns a message indicating that the body does not match" do
            expect(subject.short_summary).to include "(request body did not match)"
          end
        end
        context "when the headers do not match" do
          let(:diff_1) { {headers: nil} }
          it "returns a message indicating that the body does not match" do
            expect(subject.short_summary).to include "(request headers did not match)"
          end
        end
        context "when the headers and body do not match" do
          let(:diff_1) { {body: nil, headers: nil} }
          let(:diff_2) { {body: nil, headers: nil} }
          it "returns a message indicating that the headers and body do not match" do
            expect(subject.short_summary).to include "(request body and headers did not match)"
          end
        end
      end
    end
  end
end