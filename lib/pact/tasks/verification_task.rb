require 'rake/tasklib'

=begin
  To create a rake pact:verify:<something> task

  Pact::VerificationTask.new(:head) do | pact |
    pact.uri 'http://master.cd.vpc.realestate.com.au/browse/BIQ-MAS/latestSuccessful/artifact/JOB2/Pacts/mas-contract_transaction_service.json'
     pact.uri 'http://master.cd.vpc.realestate.com.au/browse/BIQ-IMAGINARY-CONSUMER/latestSuccessful/artifact/JOB2/Pacts/imaginary_consumer-contract_transaction_service.json'
  end

  The pact.uri may be a local file system path or a remote URL.

  To run a pact:verify:xxx task you need to define a pact_helper.rb, ideally in spec/service_consumers.
  It should contain your service_provider definition, and load any provider state definition files.
  It should also load all your app's dependencies (eg by calling out to spec_helper)

  Eg.

  require 'spec_helper'
  require 'provider_states_for_my_consumer'

  Pact.service_provider "My Provider" do
    app { TestApp.new }
  end

=end

module Pact
  class VerificationTask < ::Rake::TaskLib

    attr_reader :pact_spec_configs
    attr_accessor :rspec_opts
    attr_accessor :ignore_failures
    attr_accessor :_pact_helper

    def initialize(name)
      @rspec_opts = nil
      @ignore_failures = false
      @pact_spec_configs = []
      @name = name
      yield self
      rake_task
    end

    def pact_helper(pact_helper)
      @pact_spec_configs << { pact_helper: pact_helper }
    end

    def uri(uri, options = {})
      @pact_spec_configs << {uri: uri, pact_helper: options[:pact_helper]}
    end

    private

    attr_reader :name

    # def parse_pactfile config
    #   Pact::ConsumerContract.from_uri config[:uri]
    # end

    # def publish_report config, output, result, provider_ref, reports_dir
    #   consumer_contract = parse_pactfile config
    #   #TODO - when checking out a historical version, provider ref will be prod, however it will think it is head. Fix this!!!!
    #   report = Provider::VerificationReport.new(
    #     :result => result,
    #     :output => output,
    #     :consumer => {:name => consumer_contract.consumer.name, :ref => name},
    #     :provider => {:name => consumer_contract.provider.name, :ref => provider_ref}
    #   )

    #   FileUtils.mkdir_p reports_dir
    #   File.open("#{reports_dir}/#{report.report_file_name}", "w") { |file| file << JSON.pretty_generate(report) }
    # end

    def rake_task
      namespace :pact do

        desc "Verify provider against the consumer pacts for #{name}"
        task "verify:#{name}" do |t, args|

          require 'pact/tasks/task_helper'

          exit_statuses = pact_spec_configs.collect do | config |
            Pact::TaskHelper.execute_pact_verify config[:uri], config[:pact_helper], rspec_opts, { ignore_failures: ignore_failures }
          end

          Pact::TaskHelper.handle_verification_failure do
            exit_statuses.count{ | status | status != 0 }
          end

        end
      end
    end
  end
end
