require 'spec_helper'
require 'pact/consumer/configuration'

module Pact::Consumer::Configuration

  describe MockService do

    let(:world) { Pact::Consumer::World.new }
    let(:port_number) { 1234 }
    before do
      Pact.clear_configuration
      allow(Pact::MockService::AppManager.instance).to receive(:register_mock_service_for).and_return(port_number)
      allow(Pact).to receive(:consumer_world).and_return(world)
    end

    describe "configure_consumer_contract_builder" do
      let(:consumer_name) {'consumer'}
      subject {
        MockService.build :mock_service, consumer_name, provider_name do
          port port_number
          standalone true
          verify true
        end
      }

      let(:provider_name) { 'Mock Provider' }
      let(:consumer_contract_builder) { instance_double('Pact::Consumer::ConsumerContractBuilder') }
      let(:url) { "http://localhost:#{port_number}" }

      it "adds a verification to the Pact configuration" do
        allow(Pact::Consumer::ConsumerContractBuilder).to receive(:new).and_return(consumer_contract_builder)
        subject
        expect(consumer_contract_builder).to receive(:verify)
        Pact.configuration.provider_verifications.first.call
      end

      context "when standalone" do
        it "does not register the app with the AppManager" do
          expect(Pact::MockService::AppManager.instance).to_not receive(:register_mock_service_for)
          subject
        end
      end
      context "when not standalone" do
        subject {
          MockService.build :mock_service, consumer_name, provider_name do
            port port_number
            standalone false
            verify true
            pact_specification_version '1'
          end
        }
        it "registers the app with the AppManager" do
          expect(Pact::MockService::AppManager.instance).to receive(:register_mock_service_for).
            with(provider_name, url, pact_specification_version: '1', find_available_port: false).
            and_return(port_number)
          subject
        end
      end

      context "without port specification" do
        let(:url) { 'http://localhost' }
        subject { MockService.build(:mock_service, consumer_name, provider_name) {} }

        it "registers the app with the AppManager with find_available_port option" do
          expect(Pact::MockService::AppManager.instance).to receive(:register_mock_service_for).
            with(provider_name, url, pact_specification_version: nil, find_available_port: true).
            and_return(port_number)
          subject
        end
      end

      context "without port specification and old pact-mock_service" do
        let(:url) { 'http://localhost' }
        subject { MockService.build(:mock_service, consumer_name, provider_name) {} }

        it "checks and raises an error" do
          expect(Pact::MockService::AppManager.instance).to receive(:register_mock_service_for).
            with(provider_name, url, pact_specification_version: nil, find_available_port: true).
            and_return(nil)
          expect { subject }.to raise_error(/pact-mock_service.+does not support/)
        end
      end
    end
  end
end
