require 'pact/consumer/rspec'

Pact.service_consumer 'Pact Ruby' do
  has_pact_with 'Pact Broker' do
    mock_service :pact_broker do
      port 1234
      pact_specification_version '2.0.0'
    end
  end
end
