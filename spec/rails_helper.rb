# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

# Engine root is used by rails_configuration to correctly
# load fixtures and support files
require 'pathname'
ENGINE_ROOT = Pathname.new(File.expand_path(__dir__))

puts "Loading Rails environment for tests from #{ENGINE_ROOT}"
require 'webmock'
require 'vcr'
require 'faraday'
require 'gruf'
require 'gruf/rspec'
# require "yabeda" # we have to require it becase of this https://github.com/yabeda-rb/yabeda/pull/38

require 'combustion'
puts "Rails root: #{Rails.root}"

begin
  Combustion.initialize! :action_controller do
    config.log_level = :fatal if ENV['LOG'].to_s.empty?
  end
rescue StandardError => e
  # Fail fast if application couldn't be loaded
  warn "💥 Failed to load the app: #{e.message}\n#{e.backtrace.join("\n")}"
  exit(1)
end

require 'rspec/rails'
puts "Rails root: #{Rails.root}"
# Add additional requires below this line. Rails is not loaded until this point!

Dir["#{__dir__}/support/vcr.rb"].sort.each { |f| require f }
# Dir["#{__dir__}/support/**/*.rb"].sort.each { |f| require f }

# Optional dependencies
unless RUBY_PLATFORM =~ /win32|x64-mingw32|x64-mingw-ucrt/
  require 'sbmt/kafka_consumer'
  require 'sbmt/kafka_producer'
end

# Monkey patch Gruf::Server to remove QUIT from KILL_SIGNALS for windows compatibility
if Gem.win_platform?
  warn '[⚠️] Windows platform detected, monkey patching Gruf::Server to remove QUIT from KILL_SIGNALS'
  module Gruf
    class Server
      remove_const(:KILL_SIGNALS) if const_defined?(:KILL_SIGNALS)
      KILL_SIGNALS = %w[INT TERM].freeze
    end
  end
end
