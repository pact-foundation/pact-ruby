require 'spec_helper'
require 'pact/configuration'
require 'pact/consumer/dsl'

describe "configure" do

 before do
    Pact.clear_configuration
    Pact::Consumer::AppManager.instance.clear_all

    Pact.configure do | config |
      config.consumer do
        name "My Consumer"
      end

      config.producer :my_other_service do
        port 1235
        name "My Other Service"
        standalone false
      end
    end

    Pact.with_producer "My Service" do
      service :my_service do
        port 1234
        standalone true
      end
    end
  end

  describe "consumer" do
    it "should be configured" do
      Pact.configuration.consumer.name.should eq "My Consumer"
    end
  end

  describe "producers" do
    include Pact::Consumer::MockProducers

    it "should have defined methods in MockServices for the producers" do
      my_service.should be_instance_of Pact::Consumer::MockProducer
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