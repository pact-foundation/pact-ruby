require 'find_a_port'
require 'thor'
require 'thwait'
require 'pact/consumer'
require 'rack/handler/webrick'

module Pact
  class App < Thor

    desc 'verify', "Verify a pact"
    method_option :pact_helper, aliases: "-h", desc: "Pact helper file", :required => true
    method_option :pact_uri, aliases: "-p", desc: "Pact URI"

    def verify
      RunPactVerification.call(options)
    end

    desc 'service', "Start a mock service"
    method_option :port, aliases: "-p", desc: "Port on which to run the service"
    method_option :log, aliases: "-l", desc: "File to which to log output"
    method_option :quiet, aliases: "-q", desc: "If true, no admin messages will be shown"

    def service
      RunStandaloneMockService.call(options)
    end

    private

    def log message
      puts message unless options[:quiet]
    end
  end

  class RunPactVerification

    def self.call options
      require 'pact/provider/pact_spec_runner'

      load options[:pact_helper]
      pact_spec_options = {criteria: SpecCriteria.call}

      exit_code = if options[:pact_uri]
        Pact::Provider::PactSpecRunner.new([{uri: options[:pact_uri]}], pact_spec_options).run
      else
        pact_verifications = Pact.configuration.pact_verifications
        verification_configs = pact_verifications.collect { | pact_verification | { :uri => pact_verification.uri }}
        raise "Please configure a pact to verify" if verification_configs.empty?
        Pact::Provider::PactSpecRunner.new(verification_configs, options).run
      end
      exit 1 unless exit_code == 0
    end

  end

  class RunStandaloneMockService

    def self.call options
      service_options = {}
      if options[:log]
        log = File.open(options[:log], 'w')
        log.sync = true
        service_options[:log_file] = log
      end

      port = options[:port] || FindAPort.available_port
      mock_service = Consumer::MockService.new(service_options)
      trap(:INT) { Rack::Handler::WEBrick.shutdown }
      Rack::Handler::WEBrick.run(mock_service, :Port => port, :AccessLog => [])
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
