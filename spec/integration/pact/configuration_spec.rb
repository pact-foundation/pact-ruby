require 'spec_helper'
require 'pact/configuration'
require 'pact/consumer/dsl'
require 'pact/consumer/configuration_dsl'
require 'pact/producer/configuration_dsl'

describe "configure" do

 before do
    Pact.clear_configuration
    Pact::Consumer::AppManager.instance.clear_all

    Pact.configure do | config |
      config.service_consumer do
        name "My Consumer"
      end
    end

    Pact.with_service_provider "My Service" do
      mock_service :my_service do
        port 1234
        standalone true
      end
    end

    Pact.with_service_provider "My Other Service" do
      mock_service :my_other_service do
        port 1235
        standalone false
      end
    end
  end

  describe "configuration" do
    it "should return the same configuration object each time" do
      expect(Pact.configuration).to equal(Pact.configuration)
    end
  end

  describe "consumer" do
    it "should be configured" do
      Pact.configuration.consumer.name.should eq "My Consumer"
    end
  end

  describe "producers" do
    include Pact::Consumer::ConsumerContractBuilders

    it "should have defined methods in MockServices for the producers" do
      my_service.should be_instance_of Pact::Consumer::ConsumerContractBuilder
    end

    context "when standalone is true" do
      it "is not registerd with the AppManager" do
        Pact::Consumer::AppManager.instance.app_registered_on?(1234).should be_false
      end
    end

    context "when standalone is false" do
      it "should register the MockServices on their given ports if they are not" do
        Pact::Consumer::AppManager.instance.app_registered_on?(1235).should be_true
      end
    end
  end
end