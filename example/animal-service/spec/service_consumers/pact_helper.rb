require 'pact/provider/rspec'

require "./spec/service_consumers/provider_states_for_zoo_app"

Pact.service_provider 'Animal Service' do

  honours_pact_with "Zoo App" do
    pact_uri '../zoo-app/spec/pacts/zoo_app-animal_service.json'
  end

end
