require 'pact/consumer'
require 'pact/consumer/rspec'
load 'pact/consumer/world.rb'
require 'faraday'

describe "A service consumer side of a pact", :pact => true  do
  context "with a provider state" do
    before do
      Pact.clear_configuration

      Pact.service_consumer "Consumer" do
        has_pact_with "Zebra Service" do
          mock_service :zebra_service do
            verify false
            port 1235
          end
        end
      end
    end

    let(:body) { 'That is some good Mallory.' }
    let(:zebra_header) { '*.zebra.com' }

    it "goes like this" do
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
          'Content-Type' => 'text/html',
          'Zebra-Origin' => Pact::Term.new(matcher: /\*/, generate: zebra_header)
        },
        body: Pact::Term.new(matcher: /Mallory/, generate: body)
      )

      response = Faraday.get(zebra_service.mock_service_base_url + "/mallory", nil, {'Accept' => 'text/html'})
      expect(response.body).to eq body
      expect(response.headers['Zebra-Origin']).to eq zebra_header

      interactions = Pact::ConsumerContract.from_json(zebra_service.write_pact).interactions
      expect(interactions.first.provider_state).to eq("the_zebras_are_here")
    end
  end
end
