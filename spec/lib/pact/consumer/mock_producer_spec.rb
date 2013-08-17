require 'spec_helper'
require 'fileutils'
require 'pathname'

module Pact
	module Consumer
		describe MockProducer do

			describe "update_pactfile" do
				let(:pacts_dir) { Pathname.new("./tmp/pactfiles") }
				let(:expected_pact_path) { pacts_dir + "test_consumer-test_service.json" }
				let(:expected_pact_string) { 'the_json' }

				before do
					FileUtils.rm_rf pacts_dir
					FileUtils.mkdir_p pacts_dir
					mock_producer = MockProducer.new(pacts_dir.to_s)
					JSON.should_receive(:pretty_generate).with(instance_of(Pact::ConsumerContract)).and_return(expected_pact_string)
					mock_producer.consumer("test_consumer")
					mock_producer.assuming_a_service("test_service")
					mock_producer.instance_variable_set('@interactions', { "some description" => double("interaction", as_json: "something") })
					mock_producer.update_pactfile
				end

			  it "should write to a file specified by the consumer and producer name" do
			  	File.exist?(expected_pact_path).should be_true
			  end

			  it "should write the interactions to the file" do
			  	File.read(expected_pact_path).should eql expected_pact_string
			  end
			end
		end
	end
end