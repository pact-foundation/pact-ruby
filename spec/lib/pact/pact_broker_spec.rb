require 'pact/pact_broker'
require 'pact/provider/pact_uri'

module Pact
  module PactBroker
    describe ".fetch_pact_uris" do
      before do
        allow(Pact::PactBroker::FetchPacts).to receive(:call).and_return([pact_uri])
      end

      let(:pact_uri) { Pact::Provider::PactURI.new("http://pact") }

      subject { Pact::PactBroker.fetch_pact_uris("foo") }

      it "calls Pact::PactBroker::FetchPacts" do
        expect(Pact::PactBroker::FetchPacts).to receive(:call).with("foo")
        subject
      end

      it "returns a list of string URLs" do
        expect(subject).to eq ["http://pact"]
      end
    end

    describe ".fetch_wip_pact_uris" do
      before do
        allow(Pact::PactBroker::FetchWipPacts).to receive(:call).and_return([pact_uri])
      end

      let(:pact_uri) { Pact::Provider::PactURI.new("http://pact") }

      subject { Pact::PactBroker.fetch_wip_pact_uris("foo") }

      it "calls Pact::PactBroker::FetchWipPacts" do
        expect(Pact::PactBroker::FetchWipPacts).to receive(:call).with("foo")
        subject
      end

      it "returns a list of string URLs" do
        expect(subject).to eq ["http://pact"]
      end
    end
  end
end
