require 'pact/pact_broker/fetch_pacts'

module Pact
  module PactBroker
    describe FetchPacts do
      describe "call" do
        before do
          allow(Pact.configuration).to receive(:output_stream).and_return(double('output stream').as_null_object)
          stub_request(:get, "http://broker.org/").to_return(status: 500, body: "foo", headers: {})
        end

        let(:provider) { "Foo"}
        let(:tags) { ["master", "prod"] }
        let(:broker_base_url) { "http://broker.org" }
        let(:http_client_options) { {} }

        subject { FetchPacts.call(provider, tags, broker_base_url, http_client_options)}

        let(:subject_with_rescue) do
          begin
            subject
          rescue Pact::Error
            # can't be bothered stubbing out everything to make the rest of the code execute nicely
            # when all we care about is the message
          end
        end

        context "when there is an error retrieving the index resource" do
          it "raises a Pact::Error" do
            expect { subject }.to raise_error Pact::Error, /500.*foo/
          end
        end

        context "when there is a HAL relation missing" do
          before do
            stub_request(:get, "http://broker.org/").to_return(status: 200, body: {"_links" => {} }.to_json, headers: {})
          end

          it "raises a Pact::Error" do
            expect { subject }.to raise_error Pact::Error, /Could not find relation/
          end
        end

        context "for the latest tag" do
          it "logs a message" do
            expect(Pact.configuration.output_stream).to receive(:puts).with("INFO: Fetching pacts for Foo from http://broker.org for tags: latest master, latest prod")
            subject_with_rescue
          end
        end

        context "with a fallback tag" do
          let(:tags) { [{ name: "branch", fallback: "master" }] }

          it "logs a message" do
            expect(Pact.configuration.output_stream).to receive(:puts).with("INFO: Fetching pacts for Foo from http://broker.org for tags: latest branch (or master if not found)")
            subject_with_rescue
          end
        end

        context "when all: true" do
          let(:tags) { [{ name: "prod", all: true }] }

          it "logs a message" do
            expect(Pact.configuration.output_stream).to receive(:puts).with("INFO: Fetching pacts for Foo from http://broker.org for tags: all prod")
            subject_with_rescue
          end
        end
      end
    end
  end
end
