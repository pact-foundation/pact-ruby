require 'find_a_port'
require 'thor'
require 'thwait'
require 'pact/consumer'
require 'rack/handler/webrick'

module Pact
  class CLI < Thor

    desc 'verify', "Verify a pact"
    method_option :pact_helper, aliases: "-h", desc: "Pact helper file", :required => true
    method_option :pact_uri, aliases: "-p", desc: "Pact URI"

    def verify
      RunPactVerification.call(options)
    end

    private

    def log message
      puts message unless options[:quiet]
    end
  end

  class RunPactVerification

    attr_reader :options

    def initialize options
      @options = options
    end

    def self.call options
      new(options).call
    end


    def call
      initialize_rspec
      setup_load_path
      load_pact_helper
      run_specs
    end

    private

    def initialize_rspec
      # With RSpec3, if the pact_helper loads a library that adds its own formatter before we set one,
      # we will get a ProgressFormatter too, and get little dots sprinkled throughout our output.
      require 'pact/rspec'
      ::RSpec.configuration.add_formatter Pact::RSpec.formatter_class
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
      exit_code = if options[:pact_uri]
        run_with_pact_uri
      else
        run_with_configured_pacts
      end
      exit 1 unless exit_code == 0
    end

    def run_with_pact_uri
      Pact::Provider::PactSpecRunner.new([{uri: options[:pact_uri]}], pact_spec_options).run
    end

    def run_with_configured_pacts
      pact_verifications = Pact.configuration.pact_verifications
      verification_configs = pact_verifications.collect { | pact_verification | { :uri => pact_verification.uri }}
      raise "Please configure a pact to verify" if verification_configs.empty?
      Pact::Provider::PactSpecRunner.new(verification_configs, options).run
    end

    def pact_spec_options
      {criteria: SpecCriteria.call}
    end

  end

  class SpecCriteria

    def self.call
      criteria = {}

      description = ENV["PACT_DESCRIPTION"]
      criteria[:description] = Regexp.new(description) if description

      provider_state = ENV["PACT_PROVIDER_STATE"]
      if provider_state
        if provider_state.length == 0
          criteria[:provider_state] = nil #Allow PACT_PROVIDER_STATE="" to mean no provider state
        else
          criteria[:provider_state] = Regexp.new(provider_state)
        end
      end

      criteria
    end
  end
end
