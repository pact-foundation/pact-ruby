require 'rake/tasklib'
require 'pact/producer/pact_spec_runner'

=begin
	To create a rake pact:verify:<something> task

	Pact::VerificationTask.new(:head) do | pact |
	  pact.uri 'http://master.cd.vpc.realestate.com.au/browse/BIQ-MAS/latestSuccessful/artifact/JOB2/Pacts/mas-contract_transaction_service.json',
	              support_file: './spec/consumers/pact_helper', consumer: 'monitoring-and-alerting-system'
    pact.uri 'http://master.cd.vpc.realestate.com.au/browse/BIQ-IMAGINARY-CONSUMER/latestSuccessful/artifact/JOB2/Pacts/imaginary_consumer-contract_transaction_service.json',
                support_file: './spec/consumers/pact_helper', consumer: 'another-imaginary-consumer'
	end

	The pact.uri may be a local file system path or a remote URL.
	The consumer option is used to specify the namespace for the producer states, useful if your producer has multiple consumers.
	The support_file should include code that makes your rack app available for the rack testing framework.
	Eg.

	module PactTestApplication
		def app
		  TestApp.new
		end
	end

	RSpec.configure do |config|
		config.include PactTestApplication
	end

	It should also load all your app's dependencies (eg by calling out to spec_helper)

=end

module Pact
	class VerificationTask < ::Rake::TaskLib
	  attr_reader :pact_spec_config

	  def initialize(name)
	    @pact_spec_config = []

	    yield self

	    namespace :pact do
	      desc "Verify producer against the consumer pacts for #{name}"
	      task "verify:#{name}" do
	        exit_status = Producer::PactSpecRunner.run(pact_spec_config)
	        fail "Did not match" if exit_status != 0
	      end
	    end
	  end

	  def uri(uri, options)
	    @pact_spec_config << {uri: uri, support_file: options[:support_file], consumer: options[:consumer]}
	  end
	end
end