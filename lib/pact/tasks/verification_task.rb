require 'rake/tasklib'
require 'pact/provider/pact_spec_runner'
require 'pact/provider/verification_report'
require 'pact/tasks/task_helper'

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
    attr_reader :pact_spec_config

    include Pact::TaskHelper
    def initialize(name)
      @pact_spec_config = []
      @name = name
      yield self
      rake_task
    end

    def uri(uri, options = {})
      @pact_spec_config << {uri: uri, support_file: options[:support_file], pact_helper: options[:pact_helper]}
    end

    private

    attr_reader :name

    def parse_pactfile config
      Pact::ConsumerContract.from_uri config[:uri]
    end

    def publish_report config, output, result, provider_ref, reports_dir
      consumer_contract = parse_pactfile config
      #TODO - when checking out a historical version, provider ref will be prod, however it will think it is head. Fix this!!!!
      report = Provider::VerificationReport.new(
        :result => result,
        :output => output,
        :consumer => {:name => consumer_contract.consumer.name, :ref => name},
        :provider => {:name => consumer_contract.provider.name, :ref => provider_ref}
      )

      FileUtils.mkdir_p reports_dir
      File.open("#{reports_dir}/#{report.report_file_name}", "w") { |file| file << JSON.pretty_generate(report) }
    end

    def rake_task
      namespace :pact do
        desc "Verify provider against the consumer pacts for #{name}"
        task "verify:#{name}", :description, :provider_state do |t, args|

          options = {}
          criteria = {}
          [:description, :provider_state].each  do |key|
            value = ENV.fetch("PACT_#{key.to_s.upcase}", args[key])
            criteria[key] = Regexp.new(value) unless value.nil?
          end
          options[:criteria] = criteria unless criteria.empty?

          exit_statuses = pact_spec_config.collect do | config |
            #TODO: Change this to accept the ConsumerContract that is already parsed, so we don't make the same request twice
            pact_spec_runner = Provider::PactSpecRunner.new([config], options)
            exit_status = pact_spec_runner.run
            publish_report config, pact_spec_runner.output, exit_status == 0, 'head', Pact.configuration.reports_dir
            exit_status
          end

          handle_verification_failure do
            exit_statuses.count{ | status | status != 0 }
          end
        end
      end
    end
  end
end
