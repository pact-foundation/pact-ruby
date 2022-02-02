require 'open-uri'
require 'rspec'
require 'rspec/core'
require 'rspec/core/formatters/documentation_formatter'
require 'pact/provider/pact_helper_locator'
require 'pact/project_root'
require 'pact/rspec'
require 'pact/provider/pact_source'
require 'pact/provider/help/write'
require 'pact/provider/verification_results/publish_all'
require 'pact/provider/rspec/pact_broker_formatter'
require 'pact/provider/rspec/json_formatter'
require 'pact/provider/rspec'
require 'pact/provider/rspec/calculate_exit_code'
require 'pact/utils/metrics'

module Pact
  module Provider
    class PactSpecRunner

      include Pact::Provider::RSpec::ClassMethods

      attr_reader :pact_urls
      attr_reader :options

      def initialize pact_urls, options = {}
        @pact_urls = pact_urls
        @options = options
        @results = nil
      end

      def run
        begin
          configure_rspec
          initialize_specs
          run_specs
        ensure
          ::RSpec.reset
          Pact.clear_provider_world
          Pact.clear_consumer_world
        end
      end

      private

      def configure_rspec
        monkey_patch_backtrace_formatter

        config = ::RSpec.configuration

        config.color = true
        config.pattern = "pattern which doesn't match any files"
        config.backtrace_inclusion_patterns = [Regexp.new(Dir.getwd), /pact.*main/]

        config.extend Pact::Provider::RSpec::ClassMethods
        config.include Pact::Provider::RSpec::InstanceMethods
        config.include Pact::Provider::TestMethods

        if options[:silent]
          config.output_stream = StringIO.new
          config.error_stream = StringIO.new
        else
          config.error_stream = Pact.configuration.error_stream
          config.output_stream = Pact.configuration.output_stream
        end

        configure_output

        config.before(:suite) do
          # Preload app before suite so the classes loaded in memory are consistent for
          # before :each and after :each hooks.
          # Otherwise the app and all its dependencies are loaded between the first before :each
          # and the first after :each, leading to inconsistent behaviour
          # (eg. with database_cleaner transactions)
          Pact.configuration.provider.app
        end

        # For the Pact::Provider::RSpec::PactBrokerFormatter
        Pact.provider_world.verbose = options[:verbose]
        Pact.provider_world.pact_sources = pact_sources
        jsons = pact_jsons
        executing_with_ruby = executing_with_ruby?

        config.after(:suite) do | suite |
          Pact.provider_world.failed_examples = suite.reporter.failed_examples
          Pact::Provider::Help::Write.call(Pact.provider_world.pact_sources) if executing_with_ruby
        end
      end

      def run_specs
        exit_code = if Pact::RSpec.runner_defined?
          ::RSpec::Core::Runner.run(rspec_runner_options)
        else
          ::RSpec::Core::CommandLine.new(NoConfigurationOptions.new)
            .run(::RSpec.configuration.output_stream, ::RSpec.configuration.error_stream)
        end

        if options[:ignore_failures]
          0
        else
          Pact::Provider::RSpec::CalculateExitCode.call(pact_sources, Pact.provider_world.failed_examples)
        end
      end

      def rspec_runner_options
        ["--options", Pact.project_root.join("lib/pact/provider/rspec/custom_options_file").to_s]
      end

      def monkey_patch_backtrace_formatter
        Pact::RSpec.with_rspec_3 do
          require 'pact/provider/rspec/backtrace_formatter'
        end
      end

      def pact_sources
        @pact_sources ||= begin
          pact_urls.collect do | pact_url |
            Pact::Provider::PactSource.new(pact_url)
          end
        end
      end

      def pact_jsons
        pact_sources.collect(&:pact_json)
      end

      def initialize_specs
        pact_sources.each do | pact_source |
          spec_options = {
            criteria: options[:criteria],
            ignore_failures: options[:ignore_failures],
            request_customizer: options[:request_customizer]
          }
          Pact::Utils::Metrics.report_metric("Pacts verified", "ProviderTest", "Completed")

          honour_pactfile pact_source, ordered_pact_json(pact_source.pact_json), spec_options
        end
      end

      def configure_output
        Pact::RSpec.with_rspec_3 do
          ::RSpec.configuration.add_formatter Pact::Provider::RSpec::PactBrokerFormatter, StringIO.new
        end

        output = options[:out] || Pact.configuration.output_stream
        if options[:format]
          formatter = options[:format] == 'json' ? Pact::Provider::RSpec::JsonFormatter : options[:format]
          # Send formatted output to $stdout for parsing, unless a file is specified
          output = options[:out] || $stdout
          ::RSpec.configuration.add_formatter formatter, output
          # Don't want to mess up the JSON parsing with INFO and DEBUG messages to stdout, so send it to stderr
          Pact.configuration.output_stream = Pact.configuration.error_stream if !options[:out]
        else
          # Sometimes the formatter set in the cli.rb get set with an output of StringIO.. don't know why
          formatter_class = Pact::RSpec.formatter_class
          pact_formatter = ::RSpec.configuration.formatters.find {|f| f.class == formatter_class && f.output == ::RSpec.configuration.output_stream}
          ::RSpec.configuration.add_formatter(formatter_class, output) unless pact_formatter
        end

        ::RSpec.configuration.full_backtrace = @options[:full_backtrace]
      end

      def ordered_pact_json(pact_json)
        return pact_json if Pact.configuration.interactions_replay_order == :recorded

        consumer_contract = JSON.parse(pact_json)
        consumer_contract["interactions"] = consumer_contract["interactions"].shuffle
        consumer_contract.to_json
      end

      def class_exists? name
        Kernel.const_get name
      rescue NameError
        false
      end

      def executing_with_ruby?
        ENV['PACT_EXECUTING_LANGUAGE'] == 'ruby'
      end

      class NoConfigurationOptions
        def method_missing(method, *args, &block)
          # Do nothing!
        end
      end
    end
  end
end
