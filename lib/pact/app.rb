require 'find_a_port'
require 'thor'
require 'thwait'
require 'pact/consumer'
require 'rack/handler/webrick'

module Pact
  class App < Thor

    desc 'service', "starts a mock service"
    method_option :port, aliases: "-p", desc: "Port on which to run the service"
    method_option :log, aliases: "-l", desc: "File to which to log output"
    method_option :quiet, aliases: "-q", desc: "If true, no admin messages will be shown"

    def service
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

    private
    def log message
      puts message unless options[:quiet]
    end
  end
end
