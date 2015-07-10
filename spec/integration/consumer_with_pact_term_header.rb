require 'pact/consumer'
require 'pact/consumer/rspec'
load 'pact/consumer/world.rb'
require 'faraday'

describe "A service consumer side of a pact", :pact => true  do
  context "when the header is a Pact::Term" do
    before do
      Pact.clear_configuration

      Pact.service_consumer "Consumer" do
        has_pact_with "Zebra Service" do
          mock_service :another_zebra_service_for_term_header do
            port 4445
          end
        end
      end
    end

    let(:body) { 'That is some good Mallory.' }

    it "matches using the term" do
      another_zebra_service_for_term_header.
        upon_receiving("a request to save an alligator").with(
          method: :put,
          path: '/alligators/John',
          headers: {
            'Content-Type' => term(/json/, 'application/json')
          }
        ).
        will_respond_with(status: 200)

      response = Faraday.put(another_zebra_service_for_term_header.mock_service_base_url + "/alligators/John", nil, {'Content-Type' => 'foo/json'})
      expect(response.status).to eq 200
    end
  end
end
