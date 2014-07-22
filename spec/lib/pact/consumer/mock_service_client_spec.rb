require 'spec_helper'
require 'pact/consumer/mock_service_client'

module Pact
  module Consumer
    describe MockServiceClient do

      subject { MockServiceClient.new(4444) }

      let(:administration_headers) { {'X-Pact-Mock-Service' => 'true'} }

      describe "#add_expected_interaction" do
        let(:interaction) { InteractionFactory.create }
        let(:request_body) { MockServiceInteractionExpectation.new(interaction, "localhost:1234").to_json }

        context "when successful" do
          let!(:post_interaction) do
            stub_request(:post, "localhost:4444/interactions").
              with(body: request_body, headers: administration_headers.merge('Content-Type' => "application/json")).
              to_return(status: 200)
          end

          it "sets up the expected interaction on the mock server" do
            subject.add_expected_interaction interaction
            expect(post_interaction).to have_been_made
          end
        end

      end

      describe "#verify" do

        context "when all interactions are successfully verified" do

          let!(:get_verification) do
            stub_request(:get, "localhost:4444/interactions/verification?example_description=some%20example").
              with(headers: administration_headers).
              to_return(status: 200)
          end

          it "does not throw an error" do
            subject.verify "some example"
            expect(get_verification).to have_been_made
          end
        end
      end

      describe ".clear_interactions" do
        let!(:delete_verifications) do
          stub_request(:delete, "localhost:4444/interactions?example_description=some%20example").
            with(headers: administration_headers).
            to_return(status: 200)
        end

        it "deletes the interactions" do
          MockServiceClient.clear_interactions 4444, "some example"
          expect(delete_verifications).to have_been_made
        end
      end

      describe "#write_pact" do
        let(:consumer_contract_details) { {consumer: {name: 'Consumer'}, provider: {name: 'Provider'}, pactfile_write_mode: 'update'} }
        let(:pact) { {a: 'pact'}.to_json }

        let!(:post_pact) do
          stub_request(:post, "localhost:4444/pact").
            with(headers: administration_headers.merge('Content-Type' => "application/json"), body: consumer_contract_details).
            to_return(status: 200, body: pact)
        end

        it "deletes the interactions" do
          expect(subject.write_pact(consumer_contract_details)).to eq pact
          expect(post_pact).to have_been_made
        end

      end

      describe "#log" do
        it "sends a log request to the mock server"
      end

      describe "#wait_for_interactions" do
        it "waits until there are no missing interactions"
      end
    end
  end
end

