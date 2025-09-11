# frozen_string_literal: true

require "webrick"

module Pact
  module V2
    module Provider
      class PactBrokerProxyRunner
        attr_reader :logger


        def initialize(pact_broker_host:, port: 9002, host: "127.0.0.1", pact_broker_user: nil, pact_broker_password: nil, pact_broker_token: nil, logger: nil)
          @host = host
          @port = port
          @pact_broker_host = pact_broker_host
          @pact_broker_user = pact_broker_user
          @pact_broker_password = pact_broker_password
          @pact_broker_token = pact_broker_token
          @logger = logger || Logger.new($stdout)

          @thread = nil
        end

        def proxy_url
          "http://#{@host}:#{@port}"
        end

        def start
          raise "server already running, stop server before starting new one" if @thread
            # Rack 2/3 compatibility
          begin
            require 'rack/handler/webrick'
            handler = ::Rack::Handler::WEBrick
          rescue LoadError
            require 'rackup/handler/webrick'
            handler = Class.new(Rackup::Handler::WEBrick)
          end
          @server = WEBrick::HTTPServer.new({BindAddress: @host, Port: @port}, WEBrick::Config::HTTP)
          @server.mount("/", handler, PactBrokerProxy.new(
            nil,
            backend: @pact_broker_host,
            streaming: false,
            username: @pact_broker_user || nil,
            password: @pact_broker_password || nil,
            token: @pact_broker_token || nil,
            logger: @logger
          ))

          @thread = Thread.new do
            @logger.debug "starting pact broker proxy server"
            @server.start
          end
        end

        def stop
          @logger.info("stopping pact broker proxy server")

          @server&.shutdown
          @thread&.join

          @logger.info("pact broker proxy server stopped")
        end

        def run
          start

          yield
        rescue => e
          logger.fatal("FATAL ERROR: #{e.message} #{e.backtrace.join("\n")}")
          raise
        ensure
          stop
        end
      end
    end
  end
end
