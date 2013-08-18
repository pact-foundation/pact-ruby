require 'net/http'
require 'pact/consumer'
require 'pact/consumer/rspec'


describe "A service consumer side of a pact", :pact => true  do

  it "goes a little something like this" do
    Pact.clear_configuration

    Pact.configure do | config |
      config.consumer do
        name "Consumer"
      end
    end

    Pact.with_producer "Alice Service" do
      mock_service :alice_service do
        verify true
        port 1234
      end
    end

    Pact.with_producer "Bob" do
      mock_service :bob_service do
        verify false
        port 4321
      end
    end

    alice_service.
      upon_receiving("a retrieve Mallory request").with({
      method: :get,
      path: '/mallory'
    }).
      will_respond_with({
      status: 200,
      headers: { 'Content-Type' => 'text/html' },
      body: Pact::Term.new(matcher: /Mallory/, generate: 'That is some good Mallory.')
    })

    bob_service.
      upon_receiving('a create donut request').with({
      method: :post,
      path: '/donuts',
      body: {
        "name" => Pact::Term.new(matcher: /Bob/)
      },
      headers: {'Accept' => 'text/plain', "Content-Type" => 'application/json'}
    }).
      will_respond_with({
      status: 201,
      body: 'Donut created.'
    })
    bob_service.
      upon_receiving('a delete charlie request').with({
      method: :delete,
      path: '/charlie'
    }).
      will_respond_with({
      status: 200,
      body: /deleted/
    })
    bob_service. 
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
    post_req['Accept'] = "text/plain"
    post_req['Content-Type'] = "application/json"
    post_req.body = {"name" => "Bobby"}.to_json
    bob_post_response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request post_req
    end

    expect(bob_post_response.code).to eql '201'
    expect(bob_post_response.body).to eql 'Donut created.'

    uri = URI('http://localhost:4321/alligators')
    post_req = Net::HTTP::Put.new(uri.path)
    post_req['Content-Type'] = "application/json"
    post_req.body = [{"name" => "Roger"}].to_json
    bob_post_response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request post_req
    end

    expect(bob_post_response.code).to eql '200'
    expect(bob_post_response.body).to eql([{"name" => "Roger", "age" => 20}].to_json)
    expect{ bob_service.verify('goes a little something like this') }.to raise_error /do not match/
  end

  context "with a producer state" do
    before do
      Pact.clear_configuration

      Pact.configure do | config |
        config.consumer do
          name "Consumer"
        end
      end

      Pact.with_producer "Zebra Service" do
        mock_service :zebra_service do
          verify false
          port 1235
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
        interactions.first.producer_state.should eq("the_zebras_are_here")
        sleep 1
    end
  end

end

