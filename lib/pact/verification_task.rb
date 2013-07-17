require 'rake/tasklib'
require 'pact/producer/pact_spec_runner'

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