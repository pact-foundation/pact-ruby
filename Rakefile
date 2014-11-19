require "rubygems"
require "bundler/setup"
require "bundler/gem_tasks"
require 'rspec/core/rake_task'

Dir.glob('./lib/tasks/**/*.rake').each { |task| load task }
Dir.glob('./tasks/**/*.rake').each { |task| load task }
RSpec::Core::RakeTask.new(:spec)

task :default => [:spec, 'pact:tests:all', :spec_with_active_support, 'pact:tests:all:with_active_support']

