require 'open-uri'
require 'rspec'
require 'rspec/core'
require 'rspec/core/formatters/documentation_formatter'
require 'rspec/core/formatters/json_formatter'
require 'pact/provider/pact_helper_locator'
require_relative 'rspec'


module Pact
  module Provider
    class PactSpecRunner

      include Pact::Provider::RSpec::ClassMethods

      SUPPORT_FILE_DEPRECATION_MESSAGE = "The :support_file option is deprecated. " +
        "The preferred way to specify a support file is to create a pact_helper.rb in one of the following paths: " +
        Pact::Provider::PactHelperLocater::PACT_HELPER_FILE_PATTERNS.join(", ") +
        ". If you cannot do this, you may use the :pact_helper option in place of the :support_file option."

      attr_reader :spec_definitions
      attr_reader :options
      attr_reader :output

      def initialize spec_definitions, options = {}
        @spec_definitions = spec_definitions
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
        end
      end

      private

      def require_pact_helper spec_definition
        if spec_definition[:pact_helper]
          puts "Using #{spec_definition[:pact_helper]}"
          require spec_definition[:pact_helper]
        elsif spec_definition[:support_file]
          puts "Using #{spec_definition[:support_file]}"
          $stderr.puts SUPPORT_FILE_DEPRECATION_MESSAGE
          require spec_definition[:support_file]
        else
          require 'pact/provider/client_project_pact_helper'
        end
      end

      def initialize_specs
        spec_definitions.each do | spec_definition |
          require_pact_helper spec_definition
          options = {
            consumer: spec_definition[:consumer],
            save_pactfile_to_tmp: true,
            criteria: @options[:criteria]
          }
          honour_pactfile spec_definition[:uri], options
        end
      end

      def configure_rspec
        config = ::RSpec.configuration

        config.color = true
        config.extend Pact::Provider::RSpec::ClassMethods
        config.include Pact::Provider::RSpec::InstanceMethods
        config.include Pact::Provider::TestMethods
        config.backtrace_inclusion_patterns = [/pact\/provider\/rspec/]

        config.before :each, :pact => :verify do | example |
          example_description = "#{example.example.example_group.description} #{example.example.description}"
          Pact.configuration.logger.info "Running example '#{example_description}'"
        end

        unless options[:silent]
          config.error_stream = $stderr
          config.output_stream = $stdout
        end

        formatter = ::RSpec::Core::Formatters::DocumentationFormatter.new(config.output)
        @json_formatter = ::RSpec::Core::Formatters::JsonFormatter.new(StringIO.new)
        reporter =  ::RSpec::Core::Reporter.new(formatter, @json_formatter)
        config.instance_variable_set(:@reporter, reporter)
      end

      def run_specs
        config = ::RSpec.configuration
        world = ::RSpec::world
        exit_code = config.reporter.report(world.example_count, nil) do |reporter|
          begin
            config.run_hook(:before, :suite)
            world.example_groups.ordered.map {|g| g.run(reporter)}.all? ? 0 : config.failure_exit_code
          ensure
            config.run_hook(:after, :suite)
          end
        end
        @output = @json_formatter.output_hash
        exit_code
      end
    end
  end
end
