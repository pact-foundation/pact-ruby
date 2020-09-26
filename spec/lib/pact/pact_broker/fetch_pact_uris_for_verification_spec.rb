require 'pact/pact_broker/fetch_pact_uris_for_verification'

module Pact
  module PactBroker
    describe FetchPactURIsForVerification do
      describe "call" do
        before do
          allow(Pact.configuration).to receive(:output_stream).and_return(double('output stream').as_null_object)
        end

        let(:provider) { "Foo"}
        let(:broker_base_url) { "http://broker.org" }
        let(:http_client_options) { {} }
        let(:consumer_version_selectors) { [{ tag: "cmaster", latest: true, fallbackTag: 'blah' }] }
        let(:provider_version_tags) { ["pmaster"] }

        subject { FetchPactURIsForVerification.call(provider, consumer_version_selectors, provider_version_tags, broker_base_url, http_client_options)}

        context "when there is an error retrieving the index resource" do
          before do
            stub_request(:get, "http://broker.org/").to_return(status: 500, body: "foo", headers: {})
          end

          let(:subject_with_rescue) do
            begin
              subject
            rescue Pact::Error
              # can't be bothered stubbing out everything to make the rest of the code execute nicely
              # when all we care about is the message
            end
          end

          it "raises a Pact::Error" do
            expect { subject }.to raise_error Pact::Error, /500.*foo/
          end
        end

        context "when a single tag is provided instead of an array" do

          let(:provider_version_tags) { "pmaster" }

          subject { FetchPactURIsForVerification.new(provider, consumer_version_selectors, provider_version_tags, broker_base_url, http_client_options)}

          it "wraps an array around it" do
            expect(subject.provider_version_tags).to eq ["pmaster"]
          end
        end

        context "when the beta:provider-pacts-for-verification relation does not exist" do
          before do
            allow(FetchPacts).to receive(:call)
            stub_request(:get, "http://broker.org/").to_return(status: 200, body: response_body, headers: response_headers)
          end

          let(:response_headers) { { "Content-Type" => "application/hal+json" } }
          let(:response_body) do
            {
              _links: {}
            }.to_json
          end

          it "calls the old fetch pacts code" do
            expect(FetchPacts).to receive(:call).with(provider, [{ name: "cmaster", all: false, fallback: "blah" }], broker_base_url, http_client_options)
            subject
          end
        end
      end
    end
  end
end
