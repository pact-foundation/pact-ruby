require "rubygems"
require "bundler/setup"
require "bundler/gem_tasks"
require 'rspec/core/rake_task'

Dir.glob('./lib/tasks/**/*.rake').each { |task| load task }
Dir.glob('./tasks/**/*.rake').each { |task| load task }

task :default => [:spec, 'pact:tests:all']

