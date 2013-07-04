require 'net/http'
require 'pact/consumer'
require 'pact/consumer/rspec'

module Pact::Consumer

  # TODO: hurl this into the sun - this should be configured
  # as part of RSpec config
  PACTS_PATH = File.expand_path('../../pacts', __FILE__)

  describe "A service consumer side of a pact" do

    before :all do
      AppManager.instance.register(MockService.new, 1234)
      AppManager.instance.register(MockService.new, 4321)
      AppManager.instance.spawn_all
    end

    after :all do
      AppManager.instance.kill_all
    end

    it "goes a little something like this" do
      alice_service = consumer('consumer').assuming_a_service('Alice').
      at('http://localhost:1234').
        upon_receiving("a retrieve Mallory request").with({
        method: :get,
        path: '/mallory'
      }).
        will_respond_with({
        status: 200,
        headers: { 'Content-Type' => 'text/html' },
        body: Pact::Term.new(matcher: /Mallory/, generate: 'That is some good Mallory.')
      })

      bob_service = consumer('consumer').assuming_a_service('Bob').
      at('http://localhost:4321').
        upon_receiving('a create donut request').with({
        method: :post,
        path: '/donuts',
        body: {
          "name" => Pact::Term.new(matcher: /Bob/)
        }
      }).
        will_respond_with({
        status: 201,
        body: 'Donut created.'
      }).
        upon_receiving('a delete charlie request').with({
        method: :delete,
        path: '/charlie'
      }).
        will_respond_with({
        status: 200,
        body: /deleted/
      }).
        upon_receiving('an update alligators request').with({
          method: :put,
          path: '/alligators',
          body: [{"name" => 'Roger' }]
      }).
        will_respond_with({
          status: 200,
          body: [{"name" => "Roger", "age" => 20}]
      })


      alice_response = Net::HTTP.get_response(URI('http://localhost:1234/mallory'))

      expect(alice_response.code).to eql '200'
      expect(alice_response['Content-Type']).to eql 'text/html'
      expect(alice_response.body).to eql 'That is some good Mallory.'

      uri = URI('http://localhost:4321/donuts')
      post_req = Net::HTTP::Post.new(uri.path)
      post_req.body = {"name" => "Bobby"}.to_json
      bob_post_response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request post_req
      end

      expect(bob_post_response.code).to eql '201'
      expect(bob_post_response.body).to eql 'Donut created.'

      uri = URI('http://localhost:4321/alligators')
      post_req = Net::HTTP::Put.new(uri.path)
      post_req.body = [{"name" => "Roger"}].to_json
      bob_post_response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request post_req
      end

      expect(bob_post_response.code).to eql '200'
      expect(bob_post_response.body).to eql([{"name" => "Roger", "age" => 20}].to_json)
    end

    context "with a fixture" do
      it "goes like this" do
        alice_service = consumer('consumer').assuming_a_service('Alice').
          at('http://localhost:1234').
          upon_receiving("a retrieve Mallory request").with({
            method: :get,
            path: '/mallory'
          }).
          when_in_state(:all_the_zebras).
          will_respond_with({
            status: 200,
            headers: { 'Content-Type' => 'text/html' },
            body: Pact::Term.new(matcher: /Mallory/, generate: 'That is some good Mallory.')
          })

          interactions = JSON.load(File.read(alice_service.pactfile_path))
          interactions.first['producer_state_name'].should eq('all_the_zebras')
      end
    end

  end
end
