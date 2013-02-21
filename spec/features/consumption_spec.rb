require 'net/http'
require 'pact/consumption'

module Pact::Consumption
  describe "A consumption scenario" do

    before :each do
      AppManager.instance.spawn MockService.new, 1234
      http = Net::HTTP.new('localhost', 1234)
      request = Net::HTTP::Delete.new('/interactions')
      http.request(request)
    end

    after :each do
      AppManager.instance.kill_all
    end

    it "goes a little something like this" do
      Consumer.new('Alice').assumes_a_service('Bob')
      .at('http://localhost:1234').
        when_requested_with({
        method: :get,
        path: '/mallory'
      }).
        will_respond_with({
        status: 200,
        headers: { 'Content-Type' => 'text/html' },
        body: 'That is some good Mallory.'
      })

      response = Net::HTTP.get_response(URI('http://localhost:1234/mallory'))

      expect(response.code).to eql '200'
      expect(response['Content-Type']).to eql 'text/html'
      expect(response.body).to eql 'That is some good Mallory.'
    end

  end
end
