# frozen_string_literal: true

module Pact
  module V2
    module Provider
      # inspired by Gruf::Cli::Executor
      class HttpServer
        SERVER_STOP_TIMEOUT_SEC = 15

        def initialize(options = {})
          @options = options

          @server_pid = nil

          @host = @options[:host] || "localhost"
          @logger = @options[:logger] || ::Logger.new($stdout)
          # allow any rack based app to be passed in, otherwise
          # we will load a Rails.application
          # allows for backwards compat with pact-ruby v1
          @app = @options[:app] || nil
        end

        def start
          raise "server already running, stop server before starting new one" if @thread

          @logger.info("[webrick] starting server with options: #{@options}")

          @thread = Thread.new do
            @logger.debug "[webrick] starting http server"

            # TODO: load from config.ru, if not rails and no app provided?
            # Rack 2/3 compatibility
            begin
              require 'rack/handler/webrick'
              handler = ::Rack::Handler::WEBrick
            rescue LoadError
              require 'rackup/handler/webrick'
              handler = Class.new(Rackup::Handler::WEBrick)
            end
            handler.run(@app || (defined?(Rails) ? Rails.application : nil),
              Host: @options[:host],
              Port: @options[:port],
              Logger: @logger,
              StartCallback: -> { @started = true }) do |server|
              @server = server
            end
          end
          sleep 0.001 until @started

          @logger.info("[webrick] server started")
        end

        def stop
          @logger.info("[webrick] stopping server")

          @server&.shutdown
          @thread&.join(SERVER_STOP_TIMEOUT_SEC)
          @thread&.kill

          @logger.info("[webrick] server stopped")
        end

        ##
        # Run the server
        #
        def run
          start

          yield
        rescue => e
          @logger.fatal("FATAL ERROR: #{e.message} #{e.backtrace.join("\n")}")
          raise
        ensure
          stop
        end
      end
    end
  end
end
