require 'spec_helper'
require 'pact/configuration'

describe "configure" do

 before do
    Pact.clear_configuration
    Pact::Consumer::AppManager.instance.clear_all

    Pact.configure do | config |
      config.consumer do
        name "My Consumer"
      end

      config.producer :my_service do
        port 1234
        name "My Service"
        standalone true
      end

      config.producer :my_other_service do
        port 1235
        name "My Other Service"
        standalone false
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
    it "should be configured" do
      Pact.configuration.producers.first.should be_instance_of Pact::Consumer::MockProducer
    end

    it "should have an item for each service" do
      Pact.configuration.producers.length.should eq 2
    end

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