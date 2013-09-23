require 'pact/provider/rspec'
require_relative "provider_states_for_zoo_app"


class AnimalService

  def call env
    response_body = {}
    if env['PATH_INFO'] == '/alligators'
      response_body = {'name' => 'Bob'}.to_json
    end
    [200, {'Content-Type' => 'application/json'}, [response_body]]
  end
end

Pact.service_provider 'Animal Service' do
  app do
    AnimalService.new
  end

  honours_pact_with "Zoo App" do
    pact_uri '../zoo-app/spec/pacts/zoo_app-animal_service.json'
  end
end