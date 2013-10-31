require 'spec_helper'
require 'net/http'
require 'pact/consumer'
require 'pact/consumer/rspec'

describe "A service consumer side of a pact", :pact => true  do

  context "with more than one matching interaction found" do
    let(:expected_response) do
      {"message"=>"Multiple interaction found for GET /path", "matching_interactions"=>[{"description"=>"a request", "request"=>{"method"=>"get", "path"=>"/path", "body"=>{"a"=>"some body"}, "headers"=>{"Content-Type"=>"application/json"}}}, {"description"=>"an identical request", "request"=>{"method"=>"get", "path"=>"/path", "body"=>{"a"=>"some body"}, "headers"=>{"Content-Type"=>"application/json"}}}]}
    end

    it "returns an error" do
      Pact.clear_configuration

      Pact.service_consumer "Consumer" do
        has_pact_with "Mary Service" do
          mock_service :mary_service do
            verify false
            port 1237
          end
        end
      end

      mary_service
        .given("something")
        .upon_receiving("a request")
        .with(method: 'get', path: '/path', body: {a: 'some body'}, headers: {'Content-Type' => 'application/json'})
        .will_respond_with(status: 200)


      mary_service
        .upon_receiving("an identical request")
        .with(method: 'get', path: '/path', body: {a: 'some body'}, headers: {'Content-Type' => 'application/json'})
        .will_respond_with(status: 200)

      uri = URI('http://localhost:1237/path')
      post_req = Net::HTTP::Get.new(uri.path)
      post_req['Content-Type'] = "application/json"
      post_req.body = {a: "some body"}.to_json
      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request post_req
      end

      expect(JSON.load(response.body)).to eq expected_response
    end

  end

  context "with no matching interaction found" do

    let(:expected_response) do
      {
        "message"=>"No interaction found for GET /path",
        "interaction_diffs"=>[{
          "description" => "a request that will not be properly matched",
          "provider_state" => "something",
          "body"=>{
            "a"=>{
              "expected"=>"some body",
              "actual"=>"not matching body"
            }
          }
        }]
      }
    end

    it "returns an error" do
      Pact.clear_configuration

      Pact.service_consumer "Consumer" do
        has_pact_with "Mary Service" do
          mock_service :mary_service do
            verify false
            port 1236
          end
        end
      end

      mary_service
        .given("something")
        .upon_receiving("a request that will not be properly matched")
        .with(method: 'get', path: '/path', body: {a: 'some body'}, headers: {'Content-Type' => 'application/json'})
        .will_respond_with(status: 200)

      uri = URI('http://localhost:1236/path')
      post_req = Net::HTTP::Get.new(uri.path)
      post_req['Content-Type'] = "application/json"
      post_req.body = {a: "not matching body"}.to_json
      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request post_req
      end

      expect(JSON.load(response.body)).to eq expected_response
    end
  end

  context "with a provider state" do
    before do
      Pact.clear_configuration

      Pact.service_consumer "Consumer" do
        has_pact_with "Zebra Service" do
          mock_service :zebra_service do
            verify false
            port 1235
          end
        end
      end
    end

    it "goes like this" do
      zebra_service.
        given(:the_zebras_are_here).
        upon_receiving("a retrieve Mallory request").with({
          method: :get,
          path: '/mallory',
          headers: {'Accept' => 'text/html'}
        }).
        will_respond_with({
          status: 200,
          headers: { 'Content-Type' => 'text/html' },
          body: Pact::Term.new(matcher: /Mallory/, generate: 'That is some good Mallory.')
        })

        interactions = Pact::ConsumerContract.from_json(File.read(zebra_service.consumer_contract.pactfile_path)).interactions
        interactions.first.provider_state.should eq("the_zebras_are_here")
        sleep 1
    end
  end

  context "with multiple headers" do
    before do
      Pact.clear_configuration
      Pact.service_consumer "Consumer" do
        has_pact_with "Multi Headers Service" do
          mock_service :multi_headers_service do
            verify true
            port 1240
          end
        end
      end

      multi_headers_service.
        given("there are multiple headers").
        upon_receiving("a request with multiple headers").
        with(method: :get, path: '/something', headers: {'X-Something' => "1, 2"}).
        will_respond_with(status: 200)
    end

    it "handles multiple headers with the same name in a comma separated list" do
        interactions = Pact::ConsumerContract.from_json(File.read(multi_headers_service.consumer_contract.pactfile_path)).interactions
        expect(interactions.first.request.headers['X-Something']).to eq("1, 2")

        uri = URI('http://localhost:1240/something')
        post_req = Net::HTTP::Get.new(uri.path)
        post_req.add_field('X-Something', '1')
        post_req.add_field('X-Something', '2')
        response = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request post_req
        end
    end

  end

  context "with a async interaction with provider" do
    before do
      Pact.clear_configuration

      Pact.service_consumer "Consumer" do
        has_pact_with "Zebra Service" do
          mock_service :zebra_service do
            verify true
            port 1239
          end
        end
      end
    end

    it "goes like this" do
      zebra_service.
          given(:the_zebras_are_here).
          upon_receiving("a retrieve Mallory request").
          with({
            method: :get,
            path: '/mallory'
          }).
          will_respond_with({status: 200})

      async_interaction { Net::HTTP.get_response(URI('http://localhost:1239/mallory'))}

      zebra_service.wait_for_interactions wait_max_seconds: 1, poll_interval: 0.1
    end

    def async_interaction
      Thread.new do
        sleep 0.2
        yield
      end
    end

  end

end

