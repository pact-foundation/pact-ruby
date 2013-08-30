require 'spec_helper'
require 'pact/consumer/dsl'

module Pact::Consumer::DSL

   describe Service do
      before do
         Pact.clear_configuration
         Pact::Consumer::AppManager.instance.stub(:register_mock_service_for)
      end
      describe "configure_consumer_contract_builder" do
         subject { 
            Service.new :mock_service do
               port 1234
               standalone true
               verify true
            end
         }

         let(:provider_name) { 'Mock Provider'}
         let(:consumer_contract_builder) { double('Pact::Consumer::ConsumerContractBuilder').as_null_object}
         let(:url) { "http://localhost:1234"}

         it "adds a verification to the Pact configuration" do
            Pact::Consumer::ConsumerContractBuilder.stub(:new).and_return(consumer_contract_builder)
            subject.configure_consumer_contract_builder({})
            consumer_contract_builder.should_receive(:verify)
            Pact.configuration.provider_verifications.first.call
         end

         context "when standalone" do
            it "does not register the app with the AppManager" do
               Pact::Consumer::AppManager.instance.should_not_receive(:register_mock_service_for)
               subject.configure_consumer_contract_builder({})
            end
         end
         context "when not standalone" do
            subject { 
               Service.new :mock_service do
                  port 1234
                  standalone false
                  verify true
               end
            }            
            it "registers the app with the AppManager" do
               Pact::Consumer::AppManager.instance.should_receive(:register_mock_service_for).with(provider_name, url)
               subject.configure_consumer_contract_builder({:provider_name => provider_name })
            end
         end         
      end
   end
end