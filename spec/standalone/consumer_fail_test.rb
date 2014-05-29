require 'pact/consumer/rspec'
require './spec/support/active_support_if_configured'

Pact.service_consumer "Standalone Consumer" do
  has_pact_with "Standalone Provider" do
    mock_service :standalone_service do
      port 1238
    end
  end
end

class StandaloneClient

  def initialize base_url
    @base_url = base_url
  end

  def call
    uri = URI("#{@base_url}/something")
    post_req = Net::HTTP::Post.new(uri.path)
    post_req['Content-Type'] = "application/json"
    post_req.body = {a: "not matching body"}.to_json
    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request post_req
    end
    JSON.parse(response.body)
  end

end

describe StandaloneClient, pact: true do

  subject { StandaloneClient.new("http://localhost:1238") }

  describe "call" do

    let(:expected_body) { {a: "body"} }
    let(:expected_headers) { {'Content-Type' => "application/hal+json"} }

    before do
      standalone_service.
        upon_receiving("a request to create something").with(method: 'post', path: '/something', headers: expected_headers, body: expected_body).
        will_respond_with(status: 200, headers: {}, body: {a: 'response body'})

      standalone_service.
        upon_receiving("a request to create something else").with(method: 'post', path: '/something-else', headers: expected_headers, body: expected_body).
        will_respond_with(status: 200, headers: {}, body: {a: 'response body'})
    end

    it "will fail and display a helpful message" do
      subject.call
    end
  end

end