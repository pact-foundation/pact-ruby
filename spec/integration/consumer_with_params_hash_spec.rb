require 'spec_helper'
require 'net/http'
require 'pact/consumer'
require 'pact/consumer/rspec'
require 'faraday'
load 'pact/consumer/world.rb'

describe "A service consumer side of a pact", :pact => true  do

  # Helper to make Faraday requests.
  # Faraday::FlatParamsEncoder may only be needed with our current version of Faraday 0.9
  # and ensures that when there are multiple parameters of the same name, they are encoded properly. e.g. colour=blue&colour=green
  def faraday_mallory(base_url,params)
    (Faraday.new base_url, :request => {
       :params_encoder => Faraday::FlatParamsEncoder,
    }).get '/mallory', params, {'Accept' => 'application/json'}
  end

  let(:body) { 'That is some good Mallory.' }

  context 'When expecting multiple instances of the same parameter in the query' do

    before :all do
      Pact.clear_configuration

      Pact.service_consumer "Consumer" do
        has_pact_with "Zebra Service" do
          mock_service :zebra_service2 do
            verify false
            port 1241
          end
        end
      end
    end

    before do

      zebra_service2.
        given(:the_zebras_are_here).
        upon_receiving("a retrieve Mallory request").with({
          method: :get,
          path: '/mallory',
          headers: {'Accept' => 'application/json'},
          query: {colour: 'brown', size: ['small', 'large']}
        }).
        will_respond_with({
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: Pact::Term.new(matcher: /Mallory/, generate: body)
      })

    end

    it "matches when all instances are provided" do
      response= faraday_mallory(zebra_service2.mock_service_base_url, { size: ['small','large'], colour: 'brown'})
      expect(response.body).to eq body

      interactions = Pact::ConsumerContract.from_json(zebra_service2.write_pact).interactions
      expect(interactions.first.provider_state).to eq("the_zebras_are_here")
    end

    it "does not match when only the first instance is provided" do
      response = Faraday.get(zebra_service2.mock_service_base_url + "/mallory?colour=brown&size=small", nil, {'Accept' => 'application/json'})
      expect(response.body).not_to eq body
    end

    it "does not match when only the last instance is provided" do
      response = Faraday.get(zebra_service2.mock_service_base_url + "/mallory?colour=brown&size=large", nil, {'Accept' => 'application/json'})
      expect(response.body).not_to eq body
    end

    it "does not match when they are out of order" do
      response= faraday_mallory(zebra_service2.mock_service_base_url, { size: ['large','small'], colour: 'brown'})
      expect(response.body).not_to eq body
    end
  end

  context "and a complex request matching Pact Terms and multiple instances of the same parameter" do

    it "goes like this" do
      Pact.clear_configuration
      Pact.service_consumer "Consumer" do
        has_pact_with "Zebra Service" do
          mock_service :zebra_service do
            verify false
            port 1242
          end
        end
      end
      zebra_service.
        given(:the_zebras_are_here).
        upon_receiving("a retrieve Mallory request").
        with({
           method: :get,
           path: '/mallory',
           headers: {'Accept' => 'application/json'},
           query: { size: ['small',Pact::Term.new(matcher: /med.*/, generate: 'medium'),'large'], colour: 'brown', weight: '5'}
        }).
        will_respond_with({
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: Pact::Term.new(matcher: /Mallory/, generate: body)
      })
      response = faraday_mallory(zebra_service.mock_service_base_url, { weight: 5, size: ['small','medium','large'], colour: 'brown'})
      expect(response.body).to eq body

      interactions = Pact::ConsumerContract.from_json(zebra_service.write_pact).interactions
      expect(interactions.first.provider_state).to eq("the_zebras_are_here")
    end
  end
end
