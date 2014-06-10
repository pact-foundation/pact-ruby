require 'spec_helper'

module Pact::Consumer
  describe AppManager do
    before do
      AppManager.instance.clear_all
    end

    describe "start_service_for" do
      before do
        allow_any_instance_of(AppRegistration).to receive(:spawn) # Don't want process actually spawning during the tests
      end
      let(:name) { 'some_service'}
      context "for http://localhost" do
        let(:url) { 'http://localhost:1234'}
        it "starts a mock service at the given port on localhost" do
          expect_any_instance_of(AppRegistration).to receive(:spawn)
          AppManager.instance.register_mock_service_for name, url
          AppManager.instance.spawn_all
        end

        it "registers the mock service as running on the given port" do
          AppManager.instance.register_mock_service_for name, url
          expect(AppManager.instance.app_registered_on?(1234)).to eq true
        end
      end
      context "for https://" do
        let(:url) { 'https://localhost:1234'}
        it "should throw an unsupported error" do
          expect { AppManager.instance.register_mock_service_for name, url }.to raise_error "Currently only http is supported"
        end
      end
      context "for a host other than localhost" do
        let(:url) { 'http://aserver:1234'}
        it "should throw an unsupported error" do
          expect { AppManager.instance.register_mock_service_for name, url }.to raise_error "Currently only services on localhost are supported"
        end
      end
    end
  end
end
