require 'spec_helper'
require 'pact/consumer/mock_service/interaction_mismatch'

module Pact
  module Consumer
    describe InteractionMismatch do
      let(:actual_request) { instance_double('Pact::Consumer::Request::Actual', :method_and_path => 'GET /path') }
      let(:expected_request_1) { instance_double('Pact::Request::Expected') }
      let(:expected_request_2) { instance_double('Pact::Request::Expected') }
      let(:candidate_1) { instance_double('Pact::Interaction', request: expected_request_1, description_with_provider_state_quoted: "desc 1") }
      let(:candidate_2) { instance_double('Pact::Interaction', request: expected_request_2, description_with_provider_state_quoted: "desc 2") }
      let(:candidate_interactions) { [candidate_1, candidate_2] }
      subject { InteractionMismatch.new(candidate_interactions, actual_request) }
      let(:diff_1) { {body: 'diff'} }
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

      describe "to_s" do
        let(:expected_message) { "Diff with interaction: desc 1\ndiff 1\nDiff with interaction: desc 2\ndiff 2" }

        before do
          allow(Pact.configuration.diff_formatter).to receive(:call).and_return("diff 1", "diff 2")
        end

        it "creates diff output using the configured diff_formatter" do
          expect(Pact.configuration.diff_formatter).to receive(:call).with(diff_1, colour: false)
          expect(Pact.configuration.diff_formatter).to receive(:call).with(diff_2, colour: false)
          subject.to_s
        end

        it "includes a diff output in the string output" do
          expect(subject.to_s).to eq expected_message
        end
      end
    end
  end
end