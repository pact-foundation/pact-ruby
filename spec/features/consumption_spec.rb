require 'net/http'
require 'pact/consumption'
require 'pact/consumption/rspec'

module Pact::Consumption
  describe "A consumption scenario" do

    let(:app_manager) { AppManager.instance }

    before :each do
      app_manager.register(MockService.new, 1234)
      app_manager.register(MockService.new, 4321)
      app_manager.spawn_all
    end

    after :each do
      app_manager.kill_all
    end

    it "goes a little something like this" do
      assuming_a_service('Alice')
      .at('http://localhost:1234').
        upon_receiving({
        method: :get,
        path: '/mallory'
      }).
        will_respond_with({
        status: 200,
        headers: { 'Content-Type' => 'text/html' },
        body: 'That is some good Mallory.'
      })

      assuming_a_service('Bob')
      .at('http://localhost:4321').
        upon_receiving({
        method: :post,
        path: '/donuts'
      }).
        will_respond_with({
        status: 201,
        body: 'Donut created.'
      })

      alice_response = Net::HTTP.get_response(URI('http://localhost:1234/mallory'))

      expect(alice_response.code).to eql '200'
      expect(alice_response['Content-Type']).to eql 'text/html'
      expect(alice_response.body).to eql 'That is some good Mallory.'

      bob_response = Net::HTTP.post_form(URI('http://localhost:4321/donuts'), {})

      expect(bob_response.code).to eql '201'
      expect(bob_response.body).to eql 'Donut created.'
    end

  end
end
