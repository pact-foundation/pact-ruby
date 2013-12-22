require_relative '../spec_helper'
require 'pact/consumer/rspec'

Pact.service_consumer 'Zoo App' do
  has_pact_with "Animal Service" do
    mock_service :animal_service do
      port 1234
    end
  end
end

