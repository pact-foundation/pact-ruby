$: << File.expand_path("../../../lib", __FILE__)

require 'pact/provider/rspec'
require 'animal_service/db'

require_relative "provider_states_for_zoo_app"

Pact.service_provider 'Animal Service' do
  honours_pact_with "Zoo App" do
    pact_uri '../zoo-app/spec/pacts/zoo_app-animal_service.json'
  end
end

RSpec.configure do | config |
  config.before do
    AnimalService::DATABASE[:animals].truncate
  end
end