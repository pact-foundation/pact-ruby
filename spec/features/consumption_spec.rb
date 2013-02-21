require 'net/http'
require 'pact/consumption'

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
      consumer = Consumer.new('Alice')

      consumer.assumes_a_service('Bob')
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

      consumer.assumes_a_service('Charlie')
      .at('http://localhost:4321').
        upon_receiving({
        method: :post,
        path: '/donuts'
      }).
        will_respond_with({
        status: 201,
        body: 'Donut created.'
      })

      bob_response = Net::HTTP.get_response(URI('http://localhost:1234/mallory'))

      expect(bob_response.code).to eql '200'
      expect(bob_response['Content-Type']).to eql 'text/html'
      expect(bob_response.body).to eql 'That is some good Mallory.'

      charlie_response = Net::HTTP.post_form(URI('http://localhost:4321/donuts'), {})

      expect(charlie_response.code).to eql '201'
      expect(charlie_response.body).to eql 'Donut created.'
    end

  end
end
