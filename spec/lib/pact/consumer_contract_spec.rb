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
	end
end