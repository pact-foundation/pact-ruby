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
					JSON.should_receive(:pretty_generate).with(instance_of(Pact::ConsumerExpectation)).and_return(expected_pact_string)
					mock_producer.instance_variable_set('@interactions', { "some description" => double("interaction", as_json: "something") })
					mock_producer.instance_variable_set('@consumer_name', "test_consumer")
					mock_producer.instance_variable_set('@service_name', "test_service")
					mock_producer.update_pactfile
				end

			  it "should write to a file specified by the consumer and producer name" do
			  	File.exist?(expected_pact_path).should be_true
			  end

			  it "should write the interactions to the file" do
			  	File.read(expected_pact_path).should eql expected_pact_string
			  end
			end

			describe "at" do
				let (:url) { 'http://localhost:1234' }
				let (:mock_producer ) { MockProducer.new('') }
				it "should start a mock service to support the given URL" do
					AppManager.instance.should_receive(:register_mock_service_for).with(url)
					mock_producer.at(url)
				end
			end
		end
	end
end