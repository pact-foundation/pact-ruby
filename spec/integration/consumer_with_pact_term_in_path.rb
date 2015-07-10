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
          mock_service :another_zebra_service do
            port 4444
          end
        end
      end
    end

    let(:body) { 'That is some good Mallory.' }

    it "goes like this" do
      another_zebra_service.
        upon_receiving("a request for an alligator").with(
          method: :get,
          path: term(/alligators\/.*/, '/alligators/Mary'),
        ).
        will_respond_with(status: 200)

      response = Faraday.get(another_zebra_service.mock_service_base_url + "/alligators/John")
      expect(response.status).to eq 200

      interactions = Pact::ConsumerContract.from_json(another_zebra_service.write_pact).interactions
      expect(interactions.first.request.path).to eq('/alligators/Mary')
    end
  end
end
