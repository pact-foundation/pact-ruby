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

  context 'submitting a form' do

    before :all do
      Pact.clear_configuration

      Pact.service_consumer "Consumer" do
        has_pact_with "Zebra Service" do
          mock_service :zebra_service_3 do
            port 1243
          end
        end
      end
    end

    before do

      zebra_service_3.
        given("the zebras like using forms").
        upon_receiving("a create Mallory request").with({
          method: :post,
          path: '/mallory',
          headers: {'Content-Type' => 'application/x-www-form-urlencoded'},
          body: "param1=wiffle&param2=penguin"
        }).
        will_respond_with({
          status: 200
      })

    end

    let(:url) { zebra_service_3.mock_service_base_url + "/mallory" }

    it "matches form data" do
      response =  Faraday.post  url, param2: 'penguin', param1: 'wiffle'
      puts response.body
      expect(response.status).to eq 200
    end

  end
end
