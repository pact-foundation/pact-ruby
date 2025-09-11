# frozen_string_literal: true

require "webrick"

module Pact
  module V2
    module Provider
      class ProviderServerRunner
        attr_reader :logger

        SETUP_PROVIDER_STATE_PATH = "/setup-provider"
        VERIFY_MESSAGE_PATH = "/verify-message"

        def initialize(port: 9001, host: "127.0.0.1", logger: nil)
          @host = host
          @port = port
          @provider_setup_states = {}
          @provider_teardown_states = {}
          @logger = logger || Logger.new($stdout)

          @state_servlet = ProviderStateServlet.new(logger: @logger)
          @message_servlet = MessageProviderServlet.new(logger: @logger)
          @thread = nil
        end

        def state_setup_url
          "http://#{@host}:#{@port}#{SETUP_PROVIDER_STATE_PATH}"
        end

        def message_setup_url
          "http://#{@host}:#{@port}#{VERIFY_MESSAGE_PATH}"
        end

        def start
          raise "server already running, stop server before starting new one" if @thread

          @server = WEBrick::HTTPServer.new({BindAddress: @host, Port: @port}, WEBrick::Config::HTTP)
          @server.mount(SETUP_PROVIDER_STATE_PATH, @state_servlet)
          @server.mount(VERIFY_MESSAGE_PATH, @message_servlet)

          @thread = Thread.new do
            @logger.debug "starting provider setup server"
            @server.start
          end
        end

        def stop
          @logger.info("stopping provider setup server")

          @server&.shutdown
          @thread&.join

          @logger.info("provider setup server stopped")
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

        def add_message_handler(state_name, &block)
          @message_servlet.add_message_handler(state_name, &block)
        end

        def add_setup_state(state_name, use_before_setup_hook = true, &block)
          @state_servlet.add_setup_state(state_name, use_before_setup_hook, &block)
        end

        def add_teardown_state(state_name, use_after_teardown_hook = true, &block)
          @state_servlet.add_teardown_state(state_name, use_after_teardown_hook, &block)
        end

        def set_before_setup_hook(&block)
          @state_servlet.before_setup(&block)
        end

        def set_after_teardown_hook(&block)
          @state_servlet.after_teardown(&block)
        end
      end
    end
  end
end
