require 'spec_helper'
require 'pact/consumer/mock_service/interaction_replay'
require 'pact/consumer/mock_service/interaction_list'

module Pact
  module Consumer

    describe InteractionReplay do

      include Rack::Test::Methods

      let(:interaction_list) { InteractionList.new }
      let(:interactions) { [] }
      let(:interaction) do
        InteractionFactory.create 'request' => {
          'method' => 'get',
          'path' => '/path'
          },
        'response' => {
          'body' => {
            '_links' => {
              'self' => {'href' => 'http://example.org/some-resource'}
            }
          }
        }
      end

      let(:app) { InteractionReplay.new("replay", logger, interaction_list, interactions) }

      before do
        interaction_list.add interaction
      end

      context "when a matching response is found" do
        let(:parsed_response_body) { JSON.parse(last_response.body)}
        it "returns the expected response" do
          get '/path'
          expect(parsed_response_body['_links']['self']['href']).to eq 'http://example.org/some-resource'
        end
      end


    end
  end
end
