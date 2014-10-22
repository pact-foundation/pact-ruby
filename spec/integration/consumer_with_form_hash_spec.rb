require 'spec_helper'
require 'net/http'
require 'pact/consumer'
require 'pact/consumer/rspec'
require 'faraday'
load 'pact/consumer/world.rb'

describe "A service consumer side of a pact", :pact => true  do

  let(:body) { 'That is some good Mallory.' }

  context 'submitting a form specified as a Hash' do

    before :all do
      Pact.clear_configuration

      Pact.service_consumer "Consumer" do
        has_pact_with "Zebra Service" do
          mock_service :zebra_service_4 do
            port 1245
          end
        end
      end
    end

    before do

      zebra_service_4.
        given("the zebras like using forms").
        upon_receiving("a create Mallory request").with({
          method: :post,
          path: '/mallory',
          headers: {'Content-Type' => 'application/x-www-form-urlencoded'},
          body: {
            param1: Pact::Term.new(generate: 'woger', matcher: /w/),
            param2: 'penguin'
          }
        }).
        will_respond_with({
          status: 200
      })

    end

    let(:url) { zebra_service_4.mock_service_base_url + "/mallory" }
    let(:response) { Faraday.post url, param2: 'penguin', param1: 'wiffle' }
    let(:pact_json) { response; zebra_service_4.write_pact }

    it "matches form data" do
      expect(response.status).to eq 200
    end

    it "does not include any Pact::Terms" do
      expect(pact_json).to_not include "Pact::Term"
    end

    it "includes the reified form" do
      expect(pact_json).to include "param1=woger"
    end

  end
end
