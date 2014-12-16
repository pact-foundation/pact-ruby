require 'open-uri'
require 'rspec'
require 'rspec/core'
require 'rspec/core/formatters/documentation_formatter'
require 'pact/provider/pact_helper_locator'
require 'pact/project_root'
require 'pact/rspec'
require 'pact/provider/pact_source'
require 'pact/provider/help/write'

require_relative 'rspec'


module Pact
  module Provider
    class PactSpecRunner

      include Pact::Provider::RSpec::ClassMethods

      attr_reader :pact_urls
      attr_reader :options
      attr_reader :output

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

        # Sometimes the formatter set in the cli.rb get set with an output of StringIO.. don't know why
        formatter_class = Pact::RSpec.formatter_class
        pact_formatter = ::RSpec.configuration.formatters.find {|f| f.class == formatter_class && f.output == ::RSpec.configuration.output_stream}
        ::RSpec.configuration.add_formatter formatter_class unless pact_formatter
        ::RSpec.configuration.full_backtrace = @options[:full_backtrace]

        config.before(:suite) do
          # Preload app before suite so the classes loaded in memory are consistent for
          # before :each and after :each hooks.
          # Otherwise the app and all its dependencies are loaded between the first before :each
          # and the first after :each, leading to inconsistent behaviour
          # (eg. with database_cleaner transactions)
          Pact.configuration.provider.app
        end

        jsons = pact_jsons

        config.after(:suite) do
          Pact::Provider::Help::Write.call(jsons)
        end

      end

      def run_specs
        exit_code = if Pact::RSpec.runner_defined?
          ::RSpec::Core::Runner.run(rspec_runner_options)
        else
          ::RSpec::Core::CommandLine.new(NoConfigurationOptions.new)
            .run(::RSpec.configuration.output_stream, ::RSpec.configuration.error_stream)
        end
        exit_code
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
            PactBroker::Provider::PactSource.new(pact_url)
          end
        end
      end

      def pact_jsons
        pact_sources.collect(&:pact_json)
      end

      def initialize_specs
        pact_sources.each do | pact_source |
          options = {
            criteria: @options[:criteria]
          }
          honour_pactfile pact_source.uri, pact_source.pact_json, options
        end
      end

      def class_exists? name
        Kernel.const_get name
      rescue NameError
        false
      end

      class NoConfigurationOptions
        def method_missing(method, *args, &block)
          # Do nothing!
        end
      end

    end
  end
end
