require 'pact/cli/spec_criteria'

module Pact
  module Cli
    class RunPactVerification
      attr_reader :options

      def initialize options
        @options = options
      end

      def self.call options
        new(options).call
      end

      def call
        configure_output
        initialize_rspec
        setup_load_path
        load_pact_helper
        run_specs
      end

      private

      def initialize_rspec
        # With RSpec3, if the pact_helper loads a library that adds its own formatter before we set one,
        # we will get a ProgressFormatter too, and get little dots sprinkled throughout our output.
        # Load a NilFormatter here to prevent that.
        require 'rspec'
        require 'pact/rspec'
        ::RSpec.configuration.add_formatter Pact::RSpec.formatter_class.const_get('NilFormatter')
      end

      def setup_load_path
        require 'pact/provider/pact_spec_runner'
        lib = File.join(Dir.pwd, "lib") # Assume we are running from within the project root. RSpec is smarter about this.
        spec = File.join(Dir.pwd, "spec")
        $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
        $LOAD_PATH.unshift(spec) if Dir.exist?(spec) && !$LOAD_PATH.include?(spec)
      end

      def load_pact_helper
        load options[:pact_helper]
      end

      def run_specs
        exit_code = if options[:pact_uri].is_a?(String)
          run_with_pact_url_string
        elsif options[:pact_uri]
          run_with_pact_uri_object # from pact-provider-verifier
        else
          run_with_configured_pacts_from_pact_helper
        end
        exit exit_code
      end

      def run_with_pact_url_string
        pact_repository_uri_options = {}
        pact_repository_uri_options[:username] = ENV['PACT_BROKER_USERNAME'] if ENV['PACT_BROKER_USERNAME']
        pact_repository_uri_options[:password] = ENV['PACT_BROKER_PASSWORD'] if ENV['PACT_BROKER_PASSWORD']
        pact_repository_uri_options[:token] = ENV['PACT_BROKER_TOKEN']
        pact_repository_uri_options[:username] = options[:pact_broker_username] if options[:pact_broker_username]
        pact_repository_uri_options[:password] = options[:pact_broker_password] if options[:pact_broker_password]
        pact_uri = ::Pact::Provider::PactURI.new(options[:pact_uri], pact_repository_uri_options)
        Pact::Provider::PactSpecRunner.new([pact_uri], pact_spec_options).run
      end

      def run_with_pact_uri_object
        Pact::Provider::PactSpecRunner.new([options[:pact_uri]], pact_spec_options).run
      end

      def run_with_configured_pacts_from_pact_helper
        pact_urls = Pact.provider_world.pact_urls
        raise "Please configure a pact to verify" if pact_urls.empty?
        Pact::Provider::PactSpecRunner.new(pact_urls, pact_spec_options).run
      end

      def pact_spec_options
        {
          full_backtrace: options[:backtrace],
          verbose: options[:verbose] || ENV['VERBOSE'] == 'true',
          criteria: SpecCriteria.call(options),
          format: options[:format],
          out: options[:out],
          ignore_failures: options[:ignore_failures],
          request_customizer: options[:request_customizer]
        }
      end

      def configure_output
        if options[:format] == 'json' && !options[:out]
          # Don't want to mess up the JSON parsing with messages to stdout, so send it to stderr
          require 'pact/configuration'
          Pact.configuration.output_stream = Pact.configuration.error_stream
        end
      end
    end
  end
end
