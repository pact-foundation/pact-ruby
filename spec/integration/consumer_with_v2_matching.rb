require 'pact/consumer'
require 'pact/consumer/rspec'
load 'pact/consumer/world.rb'
require 'faraday'

describe "When the pact_specification_version is set to 2", :pact => true  do

  before do
    Pact.clear_configuration

    Pact.service_consumer "Consumer" do
      has_pact_with "Zebra Service" do
        mock_service :zebra_service do
          verify false
          port 1235
          pact_specification_version '2'
        end
      end
    end
  end

  let(:body) { 'That is some good Mallory.' }

  it "writes the pact with v2 matching rules" do
    zebra_service.
      given(:the_zebras_are_here).
    upon_receiving("a retrieve Mallory request").with(
      method: :get,
      path: '/mallory',
      headers: {'Accept' => 'text/html'}
    ).
    will_respond_with(
      status: 200,
      headers: {
        'Content-Type' => 'text/html'
      },
      body: term(/Mallory/, body)
    )

    response = Faraday.get(zebra_service.mock_service_base_url + "/mallory", nil, {'Accept' => 'text/html'})
    expect(response.body).to eq body
    pact_hash = JSON.parse(zebra_service.write_pact)
    expect(pact_hash['interactions'][0]['response']['matchingRules']).to be_instance_of(Hash)
  end

end
