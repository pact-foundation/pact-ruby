require 'pact/pact_broker'
require 'pact/provider/pact_uri'

module Pact
  module PactBroker
    describe ".fetch_pacts_for_verification" do
      before do
        allow(Pact::PactBroker::FetchPactsForVerification).to receive(:call).and_return([pact_uri])
      end

      let(:pact_uri) { Pact::Provider::PactURI.new("http://pact") }

      subject { Pact::PactBroker.fetch_pacts_for_verification("foo") }

      it "calls Pact::PactBroker::FetchPendingPacts" do
        expect(Pact::PactBroker::FetchPactsForVerification).to receive(:call).with("foo")
        subject
      end

      it "returns a list of pact uris" do
        expect(subject).to eq [pact_uri]
      end
    end
  end
end
