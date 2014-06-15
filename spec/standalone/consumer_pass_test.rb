require 'pact/consumer/rspec'
require './spec/support/active_support_if_configured'

Pact.service_consumer "Standalone Consumer" do
  has_pact_with "Standalone Provider" do
    mock_service :standalone_service do
      port 1237
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
    post_req.body = {a: "body"}.to_json
    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request post_req
    end
    response.body
  end

end

describe StandaloneClient, pact: true do

  subject { StandaloneClient.new(standalone_service.mock_service_base_url) }

  describe "call" do

    let(:expected_body) { {a: "body"} }
    let(:response_body) { {a: 'response body'} }

    before do
      standalone_service.
        upon_receiving("a request to create something").with(method: 'post', path: '/something', body: expected_body).
        will_respond_with(status: 200, headers: {}, body: response_body)
    end

    it "will pass" do
      expect(subject.call).to eq response_body.to_json
    end

  end

end