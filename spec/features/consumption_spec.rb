require 'net/http'
require 'pact/consumption'
require 'pact/consumption/rspec'

module Pact::Consumption

  PACTS_PATH = File.expand_path('../../pacts', __FILE__)

  describe "A consumption scenario" do

    let(:app_manager) { AppManager.instance }

    before :all do
      app_manager.register(MockService.new, 1234)
      app_manager.register(MockService.new, 4321)
      app_manager.spawn_all
    end

    after :all do
      app_manager.kill_all
    end

    it "goes a little something like this" do
      alice_service = assuming_a_service('Alice')
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

      bob_service = assuming_a_service('Bob')
      .at('http://localhost:4321').
        upon_receiving({
        method: :post,
        path: '/donuts'
      }).
        will_respond_with({
        status: 201,
        body: 'Donut created.'
      }).
        upon_receiving({
        method: :delete,
        path: '/charlie'
      }).
        will_respond_with({
        status: 204,
        body: 'No content'
      })

      alice_response = Net::HTTP.get_response(URI('http://localhost:1234/mallory'))

      expect(alice_response.code).to eql '200'
      expect(alice_response['Content-Type']).to eql 'text/html'
      expect(alice_response.body).to eql 'That is some good Mallory.'

      bob_post_response = Net::HTTP.post_form(URI('http://localhost:4321/donuts'), {})

      expect(bob_post_response.code).to eql '201'
      expect(bob_post_response.body).to eql 'Donut created.'

      bob_delete_response = Net::HTTP.post_form(URI('http://localhost:4321/donuts'), {})

      expect(bob_delete_response.code).to eql '201'
      expect(bob_delete_response.body).to eql 'Donut created.'

    end

  end
end
