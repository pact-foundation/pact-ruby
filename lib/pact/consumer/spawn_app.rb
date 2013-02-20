require 'thwait'
require 'net/http'
require 'uri'

def wait_until
  waited = 0
  wait_time = 0.1
  max_wait = 10
  while waited < max_wait do
    break if yield
    sleep wait_time
    waited += wait_time
    raise "Waited longer than #{max_wait} seconds" if waited >= max_wait
  end
end

def spawn_app app, port
  # following stolen from https://github.com/jwilger/kookaburra
  RSpec.configure do |c|
    c.before(:all, :type => :feature) do
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

RSpec.configure do |c|
  # After the tests run, kill the spawned apps
  c.after(:all, :type => :feature) do
    @spawned_app_pids.each {|pid| Process.kill(9, pid) }
    Process.wait
  end
end