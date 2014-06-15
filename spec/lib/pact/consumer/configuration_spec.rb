require 'spec_helper'
require 'pact/consumer/configuration'

module Pact::Consumer::Configuration



   describe "control_server_port" do

      before do
         Pact.clear_configuration
      end
      context "default value" do
         it "is 8888" do
            expect(Pact.configuration.control_server_port).to eq 8888
         end
      end

      context "when configured" do
         it "returns the configured value" do
            Pact.configuration.control_server_port = 1234
            expect(Pact.configuration.control_server_port).to eq 1234
         end
      end
   end

   describe MockService do

      let(:world) { Pact::Consumer::World.new }
      before do
         Pact.clear_configuration
         allow(Pact::Consumer::AppManager.instance).to receive(:register_mock_service_for)
         allow(Pact).to receive(:consumer_world).and_return(world)
      end

      describe "configure_consumer_contract_builder" do
         let(:consumer_name) {'consumer'}
         subject {
            MockService.build :mock_service, consumer_name, provider_name do
               port 1234
               standalone true
               verify true
            end
         }

         let(:provider_name) { 'Mock Provider' }
         let(:consumer_contract_builder) { instance_double('Pact::Consumer::ConsumerContractBuilder') }
         let(:url) { "http://localhost:1234" }

         it "adds a verification to the Pact configuration" do
            allow(Pact::Consumer::ConsumerContractBuilder).to receive(:new).and_return(consumer_contract_builder)
            subject
            expect(consumer_contract_builder).to receive(:verify)
            Pact.configuration.provider_verifications.first.call
         end

         context "when standalone" do
            it "does not register the app with the AppManager" do
               expect(Pact::Consumer::AppManager.instance).to_not receive(:new_register_mock_service_for)
               subject
            end
         end
         context "when not standalone" do
            subject {
               MockService.build :mock_service, consumer_name, provider_name do
                  port 1234
                  standalone false
                  verify true
               end
            }
            it "registers the app with the AppManager" do
               expect(Pact::Consumer::AppManager.instance).to receive(:new_register_mock_service_for).with(provider_name, url)
               subject
            end
         end
      end
   end
end