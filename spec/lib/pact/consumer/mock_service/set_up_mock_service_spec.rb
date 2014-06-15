require 'spec_helper'
require 'pact/consumer/mock_service/set_up_mock_service'
require 'rack/test'
module Pact
  module Consumer

    describe SetUpMockService do

      include Rack::Test::Methods

      let(:logger) { double("logger").as_null_object }
      let(:app) { SetUpMockService.new("unknown", logger) }

      describe "#call" do

        before do
          allow(Pact::Consumer::AppManager.instance).to receive(:spawn_all)
          allow(Pact::Consumer::AppManager.instance).to receive(:register_mock_service_for)
        end

        subject { post "/mock-services?port=1234" ; last_response }

        context "when a port is given" do

          it "starts up a mock service on the given port" do
            expect(Pact::Consumer::AppManager.instance).to receive(:register_mock_service_for).with("unknown", "http://localhost:1234")
            subject
          end

          it "returns a success response" do
            expect(subject.status).to eq 204
          end

          it "returns the location of the mock-service administration resource" do
            expect(subject.headers['Location']).to eq 'http://example.org:80/mock-services/1234'
          end

          it "returns the location of the mock-service" do
            expect(subject.headers['Pact-Mock-Service-Location']).to eq 'http://localhost:1234'
          end

        end

        context "when a port is not given" do
          it "finds an empty port and starts up a mock service"
        end

      end

    end
  end
end