require 'spec_helper'
require 'pact/consumer_contract'

module Pact
  describe ConsumerContract do
    describe "as_json" do

      class MockInteraction
        def as_json(options ={})
          {:mock => "interaction"}
        end
      end

      let(:service_consumer) { double('ServiceConsumer', :as_json => {:a => 'consumer'}) }
      let(:pact) { ConsumerContract.new({:interactions => [MockInteraction.new], :consumer => service_consumer }) }
      let(:expected_as_json) { {:interactions=>[{:mock=>"interaction"}], :consumer => {:a => 'consumer'} } }

      it "should return a hash representation of the Pact" do
        pact.as_json.should eq expected_as_json
      end
    end

    describe ".from_json" do
      let(:loaded_pact) { ConsumerContract.from_json(string) }
      context "when the top level object is a ConsumerContract" do
        let(:string) { '{"interactions":[{"mock":"interaction"}], "consumer": {"name" : "Bob"} }' }

        it "should create a Pact" do
          loaded_pact.should be_instance_of ConsumerContract
        end

        it "should have interactions" do
          loaded_pact.interactions.should be_instance_of Array
        end

        it "should have a consumer" do
          loaded_pact.consumer.should be_instance_of Pact::Consumer::ServiceConsumer
        end
      end
    end

    describe "find_interactions" do
      let(:consumer) { double('ServiceConsumer', :name => 'Consumer')}
      let(:interaction1) { {'description' => 'a request for food'} }
      let(:interaction2) { {'description' => 'a request for drink'} }
      subject { ConsumerContract.new(:interactions => [interaction1, interaction2], :consumer => consumer) }
      context "by description" do
        context "when no interactions are found" do
          it "returns an empty array" do
            expect(subject.find_interactions(:description => /blah/)).to eql []
          end
        end
        context "when interactions are found" do
          it "returns an array of the matching interactions" do
            expect(subject.find_interactions(:description => /request/)).to eql [interaction1, interaction2]
          end
        end
      end
    end
    describe "find_interaction" do
      let(:consumer) { double('ServiceConsumer', :name => 'Consumer')}
      let(:interaction1) { {'description' => 'a request for food'} }
      let(:interaction2) { {'description' => 'a request for drink'} }
      subject { ConsumerContract.new(:interactions => [interaction1, interaction2], :consumer => consumer) }
      context "by description" do
        context "when a match is found" do
          it "returns the interaction" do
            expect(subject.find_interaction :description => /request.*food/).to eql interaction1
          end
        end
        context "when more than one match is found" do
          it "raises an error" do
            expect{ subject.find_interaction(:description => /request/) }.to raise_error "Found more than 1 interaction matching {:description=>/request/} in pact file with Consumer."
          end
        end
        context "when a match is not found" do
          it "raises an error" do
            expect{ subject.find_interaction(:description => /blah/) }.to raise_error "Could not find interaction matching {:description=>/blah/} in pact file with Consumer."
          end
        end
      end
    end
  end 
end