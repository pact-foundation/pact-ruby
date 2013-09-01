require 'uri'
require 'net/http'
require 'rack'

# Copied shamelessly from Capybara
module Pact
  class Server
    class Middleware
      attr_accessor :error

      def initialize(app)
        @app = app
      end

      def call(env)
        if env["PATH_INFO"] == "/__identify__"
          [200, {}, [@app.object_id.to_s]]
        else
          begin
            @app.call(env)
          rescue StandardError => e
            @error = e unless @error
            raise e
          end
        end
      end
    end

    class << self
      def ports
        @ports ||= {}
      end
    end

    attr_reader :app, :port

    def initialize(app, port)
      @app = app
      @middleware = Middleware.new(@app)
      @server_thread = nil # supress warnings
      @port = port
    end

    def reset_error!
      @middleware.error = nil
    end

    def error
      @middleware.error
    end

    def host
      "localhost"
    end

    def responsive?
      return false if @server_thread && @server_thread.join(0)

      res = Net::HTTP.start(host, @port) { |http| http.get('/__identify__') }

      if res.is_a?(Net::HTTPSuccess) or res.is_a?(Net::HTTPRedirection)
        return res.body == @app.object_id.to_s
      end
    rescue SystemCallError
      return false
    end

    def run_default_server(app, port)
      require 'rack/handler/webrick'
      Rack::Handler::WEBrick.run(app, :Port => port, :AccessLog => [], :Logger => WEBrick::Log::new(nil, 0))
    end    

    def boot
      unless responsive?
        Pact::Server.ports[@app.object_id] = @port

        @server_thread = Thread.new do
          run_default_server(@middleware, @port)
        end

        Timeout.timeout(60) { @server_thread.join(0.1) until responsive? }
      end
    rescue Timeout::Error
      raise "Rack application timed out during boot"
    else
      self
    end

  end
end
