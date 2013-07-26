require 'thwait'
require 'capybara'

require 'net/http'
require 'uri'
require 'find_a_port'

module Pact
  module Consumer

    class AppManager

      include Singleton

      attr_accessor :mock_port

      def initialize
        @spawned_app_pids = []
        @registered_apps = {}
        @max_wait = 10
        @apps_spawned = false
      end

      def register_mock_service_for name, url
        uri = URI(url)
        raise "Currently only http is supported" unless uri.scheme == 'http'
        raise "Currently only services on localhost are supported" unless uri.host == 'localhost'

        log = File.open("tmp/#{name}_pact.log", 'w')
        log.sync = true
        register(MockService.new(log_file: log), URI(url).port, true)
      end

      def register(app, port = FindAPort.available_port, spawn_now = false)
        @registered_apps ||= {}
        existing = @registered_apps[port]
        raise "Port #{port} is already being used by #{existing}" if existing and not existing == app
        @registered_apps[port] = app
        spawn(app, port) if @apps_spawned || spawn_now
        port
      end

      def app_registered_on?(port)
        @registered_apps.key? port
      end

      def ports_of_registered_apps
        @registered_apps.keys
      end

      def kill_all
        @spawned_app_pids.each do |pid| 
          Process.kill(9, pid) 
          Process.wait(pid)
        end
        @spawned_app_pids = []
        @apps_spawned = false
      end

      def clear_all
        kill_all
        @registered_apps = {}
      end

      def spawn_all
        @registered_apps.each do |port, app|
          spawn(app, port)
        end
        @apps_spawned = true
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

      def spawn app, port
        # following stolen from https://github.com/jwilger/kookaburra
        @spawned_app_pids ||= []
        @spawned_app_pids << fork do
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
      end

    end
  end
end
