require 'pact/pact_broker/fetch_wip_pacts'

module Pact
  module PactBroker
    describe FetchWipPacts do
      describe "call" do
        before do
          allow(Pact.configuration).to receive(:output_stream).and_return(double('output stream').as_null_object)
        end

        let(:provider) { "Foo"}
        let(:broker_base_url) { "http://broker.org" }
        let(:http_client_options) { {} }
        subject { FetchWipPacts.call(provider, broker_base_url, http_client_options)}

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

        context "when the pb:wip-provider-pacts relation does not exist" do
          before do
            stub_request(:get, "http://broker.org/").to_return(status: 200, body: response_body, headers: response_headers)
          end

          let(:response_headers) { { "Content-Type" => "application/hal+json" } }
          let(:response_body) do
            {
              _links: {}
            }.to_json
          end

          it "returns an empty list" do
            expect(subject).to eq []
          end
        end
      end
    end
  end
end
