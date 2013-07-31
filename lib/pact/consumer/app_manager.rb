require 'thwait'
require 'capybara'

require 'net/http'
require 'uri'
require 'find_a_port'
require 'pact/logging'

module Pact
  module Consumer

    class AppRegistration
      include Pact::Logging
      attr_accessor :port
      attr_accessor :app
      attr_accessor :pid

      def initialize opts
        @max_wait = 10
        @port = opts[:port]
        @pid = opts[:pid]
        @app = opts[:app]
      end

      def kill
        logger.info "Killing #{self}"
        Process.kill(9, pid)
        Process.wait(pid)
        self.pid = nil
      end

      def not_spawned?
        !spawned?
      end

      def spawned?
        self.pid != nil
      end

      def is_a_mock_service?
        app.is_a? MockService
      end

      def to_s
        "#{app} on port #{port} with pid #{pid}"
      end

      def spawn
        # following stolen from https://github.com/jwilger/kookaburra
        logger.info "Starting app #{self}..."
        self.pid = fork do
          Capybara.server_port = port
          Capybara::Server.new(app).boot

          # This ensures that this forked process keeps running, because the
          # actual server is started in a thread by Capybara.
          ThreadsWait.all_waits(Thread.list)
        end


        wait_until do
          begin
            Net::HTTP.get_response(URI.parse("http://localhost:#{port}/index.html"))
          rescue Errno::ECONNREFUSED
            false
          end
        end
        logger.info "Started"
      end

      def wait_until
        waited = 0
        wait_time = 0.1
        while waited < @max_wait do
          break if yield
          sleep wait_time
          waited += wait_time
          raise "Waited longer than #{@max_wait} seconds" if waited >= @max_wait
        end
      end

    end

    class AppManager

      include Pact::Logging

      include Singleton

      attr_accessor :mock_port

      def initialize
        @apps_spawned = false
        @app_registrations = []
      end

      def register_mock_service_for name, url
        uri = URI(url)
        raise "Currently only http is supported" unless uri.scheme == 'http'
        raise "Currently only services on localhost are supported" unless uri.host == 'localhost'

        register(MockService.new(log_file: create_log_file(name), name: name), uri.port)
      end

      def register(app, port = FindAPort.available_port)
        existing = existing_app_on_port port
        raise "Port #{port} is already being used by #{existing}" if existing and not existing == app
        app_registration = register_app app, port
        app_registration.spawn if @apps_spawned
        port
      end

      def existing_app_on_port port
        app_registration = @app_registrations.find { |app_registration| app_registration.port == port }
        app_registration ? app_registration.app : nil
      end

      def app_registered_on?(port)
        app_registrations.any? { |app_registration| app_registration.port == port }
      end

      def ports_of_mock_services
        app_registrations.find_all(&:is_a_mock_service?).collect(&:port)
      end

      def kill_all
        app_registrations.find_all(&:spawned?).collect(&:kill)
        apps_spawned = false
      end

      def clear_all
        kill_all
        @app_registrations = []
      end

      def spawn_all
        app_registrations.find_all(&:not_spawned?).collect(&:spawn)
        @apps_spawned = true
      end

      def create_log_file service_name
        FileUtils::mkdir_p Pact.configuration.log_dir
        log = File.open(Pact.configuration.log_dir + "/#{service_name}_pact_creation.log", 'w')
        log.sync = true
        log
      end


      private

      def app_registrations
        @app_registrations
      end

      def register_app app, port
        app_registration = AppRegistration.new :app => app, :port => port
        app_registrations << app_registration
        app_registration
      end
    end
  end
end
