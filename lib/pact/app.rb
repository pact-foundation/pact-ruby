require 'capybara'
require 'find_a_port'
require 'thor'
require 'thwait'
require 'pact/consumer'

module Pact
  class App < Thor

    desc 'start', "Starts a mock service"
    method_option :port, aliases: "-p", desc: "Port on which to run the service"
    method_option :log, aliases: "-l", desc: "File to which to log output"
    method_option :quiet, aliases: "-q", desc: "If true, no admin messages will be shown"

    def start
      service_options = {}
      if options[:log]
        log = File.open(log, 'w')
        log.sync = true
        service_options[:log_file] = log
      end
      port = options[:port] || FindAPort.available_port
      service = Consumer::MockService.new(service_options)
      Capybara.server_port = port
      Capybara::Server.new(service).boot
      puts "Mock service started on http://127.0.0.1:#{port}"
      puts "Stop with Ctrl-C"
      begin
        ThreadsWait.all_waits(Thread.list)
      rescue Interrupt
        puts ""
        puts "Shutting down mock service on http://127.0.0.1:#{port}"
      end
    end

    private
    def log message
      puts message unless options[:quiet]
    end
  end
end
