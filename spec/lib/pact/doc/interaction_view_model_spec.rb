require 'spec_helper'
require 'pact/doc/interaction_view_model'

module Pact
  module Doc
    describe InteractionViewModel do

      let(:consumer_contract) { Pact::ConsumerContract.from_uri './spec/support/interaction_view_model.json'}

      let(:interaction_with_request_with_body_and_headers) { consumer_contract.find_interaction description: "a request with a body and headers" }
      let(:interaction_with_request_without_body_and_headers) { consumer_contract.find_interaction description: "a request with an empty body and empty headers" }
      let(:interaction_with_response_with_body_and_headers) { consumer_contract.find_interaction description: "a response with a body and headers" }
      let(:interaction_with_response_without_body_and_headers) { consumer_contract.find_interaction description: "a response with an empty body and empty headers" }


      subject { InteractionViewModel.new interaction, consumer_contract}

      describe "request" do

        let(:interaction) { interaction_with_request_with_body_and_headers }

        it "includes the method" do
          expect(subject.request).to include('"method"')
          expect(subject.request).to include('"get"')
        end

        it "includes the body" do
          expect(subject.request).to include('"body"')
          expect(subject.request).to include('"a body"')
        end

        it "includes the headers" do
          expect(subject.request).to include('"headers"')
          expect(subject.request).to include('"a header"')
        end

        it "includes the query" do
          expect(subject.request).to include('"query"')
          expect(subject.request).to include('"some=thing"')
        end

        it "includes the path" do
          expect(subject.request).to include('"path"')
          expect(subject.request).to include('"/path"')
        end

        it "renders the keys in a meaningful order" do
          expect(subject.request).to match /"method".*"path".*"query".*"headers".*"body"/m
        end

        context "when the body hash is empty" do

          let(:interaction) { interaction_with_request_without_body_and_headers }

          it "includes the body" do
            expect(subject.request).to include("body")
          end
        end
        context "when the headers hash is empty" do

          let(:interaction) { interaction_with_request_without_body_and_headers }

          it "does not include the headers" do
            expect(subject.request).to_not include("headers")
          end
        end
      end

      describe "response" do

        let(:interaction) { interaction_with_response_with_body_and_headers }

        it "includes the status" do
          expect(subject.response).to include('"status"')
        end

        it "includes the body" do
          expect(subject.response).to include('"body"')
          expect(subject.response).to include('"a body"')
        end
        it "includes the headers" do
          expect(subject.response).to include('"headers"')
          expect(subject.response).to include('"a header"')
        end

        it "renders the keys in a meaningful order" do
          expect(subject.response).to match /"status".*"headers".*"body"/m
        end

        context "when the body hash is empty" do

          let(:interaction) { interaction_with_response_without_body_and_headers }

          it "does not include the body" do
            expect(subject.response).to_not include("body")
          end
        end

        context "when the headers hash is empty" do

          let(:interaction) { interaction_with_response_without_body_and_headers }

          it "does not include the headers" do
            expect(subject.response).to_not include("headers")
          end
        end
      end


    end
  end
end