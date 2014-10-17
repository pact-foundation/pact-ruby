require 'spec_helper'
require 'net/http'
require 'pact/consumer'
require 'pact/consumer/rspec'
require 'faraday'
load 'pact/consumer/world.rb'

describe "A service consumer side of a pact", :pact => true  do

  context "with more than one matching interaction found" do
    let(:expected_response) do
      {"message"=>"Multiple interaction found for GET /path", "matching_interactions"=>[{"description"=>"a request", "request"=>{"method"=>"get", "path"=>"/path", "body"=>{"a"=>"some body"}, "headers"=>{"Content-Type"=>"application/json"}}}, {"description"=>"an identical request", "request"=>{"method"=>"get", "path"=>"/path", "body"=>{"a"=>"some body"}, "headers"=>{"Content-Type"=>"application/json"}}}]}
    end

    it "returns an error" do
      Pact.clear_configuration
      Pact.clear_consumer_world

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
              "EXPECTED"=>"some body",
              "ACTUAL"=>"not matching body"
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

    let(:body) { 'That is some good Mallory.' }

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
          body: Pact::Term.new(matcher: /Mallory/, generate: body)
        })

      response = Faraday.get(zebra_service.mock_service_base_url + "/mallory", nil, {'Accept' => 'text/html'})
      expect(response.body).to eq body

      interactions = Pact::ConsumerContract.from_json(zebra_service.write_pact).interactions
      expect(interactions.first.provider_state).to eq("the_zebras_are_here")
    end
  end


  # Helper to make Faraday requests.
  # Faraday::FlatParamsEncoder may only be needed with our current version of Faraday 0.9
  # and ensures that when there are multiple parameters of the same name, they are encoded properly. e.g. colour=blue&colour=green
  def faraday_mallory(base_url,params)
    (Faraday.new base_url, :request => {
        :params_encoder => Faraday::FlatParamsEncoder,
    }).get '/mallory', params, {'Accept' => 'application/json'}
  end

  context "with a provider state" do
    let(:body) { 'That is some good Mallory.' }
    Pact.service_consumer "Consumer" do
      has_pact_with "Zebra Service" do
        mock_service :zebra_service2 do
          verify false
          port 1241
        end
      end
    end
    context 'When expecting multiple instances of the same parameter in the query' do
      before do
        Pact.clear_configuration
        zebra_service2.
            given(:the_zebras_are_here).
            upon_receiving("a retrieve Mallory request").with({
                                                                  method: :get,
                                                                  path: '/mallory',
                                                                  headers: {'Accept' => 'application/json'},
                                                                  query: {colour: 'brown', size: ['small', 'large']}
                                                              }).
            will_respond_with({
                                  status: 200,
                                  headers: { 'Content-Type' => 'application/json' },
                                  body: Pact::Term.new(matcher: /Mallory/, generate: body)
                              })

      end
      it "matches when all instances are provided" do
        response= faraday_mallory(zebra_service2.mock_service_base_url, { size: ['small','large'], colour: 'brown'})
        expect(response.body).to eq body

        interactions = Pact::ConsumerContract.from_json(zebra_service.write_pact).interactions
        expect(interactions.first.provider_state).to eq("the_zebras_are_here")
      end
      it "does not match when only the first instance is provided" do
        response = Faraday.get(zebra_service2.mock_service_base_url + "/mallory?colour=brown&size=small", nil, {'Accept' => 'application/json'})
        expect(response.body).not_to eq body
      end

      it "does not match when only the last instance is provided" do
        response = Faraday.get(zebra_service2.mock_service_base_url + "/mallory?colour=brown&size=large", nil, {'Accept' => 'application/json'})
        expect(response.body).not_to eq body
      end

      it "does not match when they are out of order" do
        response= faraday_mallory(zebra_service2.mock_service_base_url, { size: ['large','small'], colour: 'brown'})
        expect(response.body).not_to eq body
      end
    end
  end
  context "with a provider state" do
    before do
      Pact.clear_configuration
      Pact.service_consumer "Consumer" do
        has_pact_with "Zebra Service" do
          mock_service :zebra_service do
            verify false
            port 1242
          end
        end
      end
    end

    let(:body) { 'That is some good Mallory.' }
    context "and a complex request matching Pact Terms and multiple instances of the same parameter"
    it "goes like this" do
      zebra_service.
          given(:the_zebras_are_here).
          upon_receiving("a retrieve Mallory request").
          with({
                   method: :get,
                   path: '/mallory',
                   headers: {'Accept' => 'application/json'},
                   query: { size: ['small',Pact::Term.new(matcher: /med.*/, generate: 'medium'),'large'], colour: 'brown', weight: '5'}
               }).
          will_respond_with({
                                status: 200,
                                headers: { 'Content-Type' => 'application/json' },
                                body: Pact::Term.new(matcher: /Mallory/, generate: body)
                            })
      response= faraday_mallory(zebra_service.mock_service_base_url, { weight: 5, size: ['small','medium','large'], colour: 'brown'})
      expect(response.body).to eq body

      interactions = Pact::ConsumerContract.from_json(zebra_service.write_pact).interactions
      expect(interactions.first.provider_state).to eq("the_zebras_are_here")
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

        uri = URI('http://localhost:1240/something')
        post_req = Net::HTTP::Get.new(uri.path)
        post_req.add_field('X-Something', '1')
        post_req.add_field('X-Something', '2')
        response = Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request post_req
        end
    end

    it "handles multiple headers with the same name in a comma separated list" do
      interactions = Pact::ConsumerContract.from_json(multi_headers_service.write_pact).interactions
      expect(interactions.first.request.headers['X-Something']).to eq("1, 2")
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

