require 'rspec/core/rake_task'
require 'pact_broker/client/tasks'

$: << './lib'

RSpec::Core::RakeTask.new(:spec)

PactBroker::Client::PublicationTask.new do | task |
  require 'zoo_app/version'
  task.consumer_version = ZooApp::VERSION
  task.pact_broker_base_url = "http://localhost:9292"
end

task :default => :spec