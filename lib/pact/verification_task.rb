require 'rake/tasklib'
require 'pact/provider/pact_spec_runner'
require_relative 'pact_task_helper'

=begin
	To create a rake pact:verify:<something> task

	Pact::VerificationTask.new(:head) do | pact |
	  pact.uri 'http://master.cd.vpc.realestate.com.au/browse/BIQ-MAS/latestSuccessful/artifact/JOB2/Pacts/mas-contract_transaction_service.json'
    pact.uri 'http://master.cd.vpc.realestate.com.au/browse/BIQ-IMAGINARY-CONSUMER/latestSuccessful/artifact/JOB2/Pacts/imaginary_consumer-contract_transaction_service.json'
	end

	The pact.uri may be a local file system path or a remote URL.
	The support_file should include code that makes your rack app available for the rack testing framework.
	Eg.

	Pact.service_provider "My Provider" do
		app { TestApp.new }
	end

	It should also load all your app's dependencies (eg by calling out to spec_helper)

=end


module Pact
	class VerificationTask < ::Rake::TaskLib
	  attr_reader :pact_spec_config

	  include PactTaskHelper
	  def initialize(name)
	    @pact_spec_config = []
	    @name = name
	    yield self
	    define_rake_task
	  end

	  def uri(uri, options = {})
	    @pact_spec_config << {uri: uri, support_file: options[:support_file]}
	  end

	  private

	  attr_reader :name

	  def define_rake_task
	  	namespace :pact do
	  	  desc "Verify provider against the consumer pacts for #{name}"
	  	  task "verify:#{name}" do
	  	    exit_status = Provider::PactSpecRunner.run(pact_spec_config)
	  	    fail failure_message if exit_status != 0
	  	  end
	  	end
	  end
	end
end