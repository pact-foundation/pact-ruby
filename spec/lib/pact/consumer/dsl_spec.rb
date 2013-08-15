require 'spec_helper'
require 'pact/consumer/dsl'
require 'pact/consumer/configuration_dsl'

module Pact::Consumer::DSL
   describe Service do
      before do
         Pact.clear_configuration
      end
      describe "configure_mock_producer" do
         subject { 
            Service.new :mock_service do
               port 1234
               standalone true
               verify true
            end
         }

         let(:mock_producer) { double('Pact::Consumer::MockProducer').as_null_object}

         it "should add a verification to the Pact configuration" do
            subject.configure_mock_producer mock_producer
            mock_producer.should_receive(:verify)
            Pact.configuration.producer_verifications.first.call
         end
      end
   end
end