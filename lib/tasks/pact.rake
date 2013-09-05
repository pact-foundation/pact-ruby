require 'pact'
require 'pact/pact_task_helper'


namespace :pact do

  include PactTaskHelper

	desc "Runs the specified pact file against the service provider"
  task :verify, :pact_uri do | t, args |
    require 'pact/provider/pact_spec_runner'
    puts "Using pact at uri #{args[:pact_uri]}"
    pact_spec_config = {uri: args[:pact_uri]}
    exit_status = Pact::Provider::PactSpecRunner.run([pact_spec_config])
    fail failure_message if exit_status != 0
  end
end
