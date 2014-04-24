require 'spec_helper'
require 'pact/consumer/mock_service/verification_get'

module Pact
  module Consumer
    describe VerificationGet do

      let(:interaction_list) { instance_double("Pact::Consumer::InteractionList")}
      let(:logger) { double("Logger").as_null_object }
      let(:log_description) { "/log/pact.log" }

      subject { VerificationGet.new('VerificationGet', logger, interaction_list, log_description) }

      its(:request_path) { should eq '/verify'}
      its(:request_method) { should eq 'GET'}


      describe "#respond" do
        let(:env) { {
          "QUERY_STRING" => "example_description=a description"
        } }

        before do
          allow(interaction_list).to receive(:all_matched?).and_return(all_matched)
        end

        let(:response) { subject.respond env }

        context "when all interactions have been matched" do
          let(:all_matched) { true }

          it "returns a 200 status" do
            expect(response.first).to eq 200
          end

          it "returns a Content-Type of text/plain" do
            expect(response[1]).to eq 'Content-Type' => 'text/plain'
          end

          it "returns a nice message" do
            expect(response.last).to eq ['Interactions matched']
          end
        end

        context "when all interactions not been matched" do
          let(:all_matched) { false }
        end

      end

    end
  end
end
