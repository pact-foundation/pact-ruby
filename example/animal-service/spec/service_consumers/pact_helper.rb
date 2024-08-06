require 'pact/provider/rspec'

require "./spec/service_consumers/provider_states_for_zoo_app"

Pact.service_provider 'Animal Service' do

  honours_pact_with "Zoo App" do
    pact_uri '../zoo-app/spec/pacts/zoo_app-animal_service.json'
  end

  ## For pact contracts from a Pact Broker

  # honours_pacts_from_pact_broker do
  #   pact_broker_base_url 'http://localhost:9292'
  #   # fail_if_no_pacts_found false # defaults to true
  # end

end
