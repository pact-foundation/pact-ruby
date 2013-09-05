require 'pact'
require 'pact/pact_task_helper'

include PactTaskHelper
namespace :pact do

	desc "Runs the specified pact file against the service provider"
  task :verify, :pact_uri, :support_file do | t, args |
    puts 'BLSH'
    require 'pact/provider/pact_spec_runner'
    puts "Using pact at uri #{args[:pact_uri]}"
    puts "Using support file #{args[:support_file]}"
    pact_spec_config = {uri: args[:pact_uri], support_file: args[:support_file]}
    exit_status = Pact::Provider::PactSpecRunner.run([pact_spec_config])
    fail failure_message if exit_status != 0
  end
end
