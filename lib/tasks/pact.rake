
namespace :pact do

  desc "Verifies the pact files configured in the pact_helper.rb against this service provider."
  task :verify do
    require 'pact/provider'
    require 'pact/pact_task_helper'
    require 'pact/provider/client_project_pact_helper'

    include PactTaskHelper

    handle_verification_failure do
      pact_verifications = Pact.configuration.pact_verifications
      verification_configs = pact_verifications.collect { | pact_verification | { :uri => pact_verification.uri }}
      Pact::Provider::PactSpecRunner.new(verification_configs).run
    end
  end

  desc "Verifies the pact at the given URI against this service provider."
  task 'verify:at', :pact_uri do | t, args |
    require 'pact/provider'
    require 'pact/pact_task_helper'

    include PactTaskHelper

    handle_verification_failure do
      puts "Verifying pact at uri #{args[:pact_uri]}"
      Pact::Provider::PactSpecRunner.new([{uri: args[:pact_uri]}]).run
    end
  end

end
