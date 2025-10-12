# frozen_string_literal: true

require 'pact/v2/rspec'
require 'net/http'
require 'json'
require 'faraday'
RSpec.describe 'HTTP transport', :pact_v2, skip_windows: true do
  has_plugin_http_pact_between 'myconsumer', 'myprovider'

  let(:matt_request) { { 'request' => { 'body' => 'hello' } } }
  let(:matt_response) { { 'response' => { 'body' => 'world' } } }

  let(:interaction) do
    new_interaction
      .given('the Matt protocol is up')
      .upon_receiving('an HTTP request to /matt')
      .with_plugin('matt', '0.1.1')
      .with_request(method: 'POST', path: '/matt', body: matt_request, headers: { 'content-type' => 'application/matt' })
      .will_respond_with(status: 200, body: matt_response, headers: { 'content-type' => 'application/matt' })
  end

  it 'returns a valid MATT message' do
    interaction.execute do |mock_server|
      uri = URI("#{mock_server.url}/matt")
      req = Net::HTTP::Post.new(uri)
      req['content-type'] = 'application/matt'
      req['accept'] = 'application/matt'
      req.body = 'MATT' + matt_request['request']['body'] + "MATT\n"

      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end

      expect(res.body).to eq('MATTworldMATT')
    end
  end
end
