
namespace :pact do

  desc "Verifies the pact files configured in the pact_helper.rb against this service provider."
  task :verify do
    require 'pact/provider'
    require 'pact/tasks/task_helper'
    require 'pact/provider/client_project_pact_helper'

    include Pact::TaskHelper

    handle_verification_failure do
      options = {criteria: spec_criteria}
      pact_verifications = Pact.configuration.pact_verifications
      verification_configs = pact_verifications.collect { | pact_verification | { :uri => pact_verification.uri }}
      raise "Please configure a pact to verify" if verification_configs.empty?
      Pact::Provider::PactSpecRunner.new(verification_configs, options).run
    end
  end

  desc "Verifies the pact at the given URI against this service provider."
  task 'verify:at', :pact_uri do | t, args |
    require 'pact/provider'
    require 'pact/tasks/task_helper'

    include Pact::TaskHelper

    handle_verification_failure do
      puts "Verifying pact at uri #{args[:pact_uri]}"
      options = {criteria: spec_criteria}
      Pact::Provider::PactSpecRunner.new([{uri: args[:pact_uri]}], options).run
    end
  end

end
