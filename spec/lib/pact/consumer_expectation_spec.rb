require 'spec_helper'
require 'pact/consumer_expectation'

module Pact
	describe ConsumerExpectation do
	  describe "as_json" do

	  	class MockInteraction
	  		def as_json(options ={})
	  			{:mock => "interaction"}
	  		end
	  	end


	  	let(:pact) { ConsumerExpectation.new({:interactions => [MockInteraction.new] }) }
	  	let(:expected_as_json) { {:interactions=>[{:mock=>"interaction"}]} }

	    it "should return a hash representation of the Pact" do
	      pact.as_json.should eq expected_as_json
	    end
	  end

	  describe ".from_json" do
		  let(:loaded_pact) { ConsumerExpectation.from_json(string) }
	  	context "when the top level object is a ConsumerExpectation" do
		  	let(:string) { '{"interactions":[{"mock":"interaction"}]}' }

		  	it "should create a Pact" do
		  		loaded_pact.should be_instance_of ConsumerExpectation
		  	end

		  	it "should have interactions" do
		  		loaded_pact.interactions.should be_instance_of Array
		  	end
	  	end
	  	context "when the top level object is an array" do
	  		let(:string) { '[{"mock":"interaction"}]' }

	  		it "should create a Pact" do
	  			loaded_pact.should be_instance_of ConsumerExpectation
	  		end

	  		it "should have interactions" do
	  			loaded_pact.interactions.should be_instance_of Array
	  		end
	  	end
	  end
	end
end