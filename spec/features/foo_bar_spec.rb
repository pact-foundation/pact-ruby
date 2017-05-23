require 'net/http'
require 'pact/consumer'
require 'pact/consumer/rspec'
load 'pact/consumer/world.rb'

# Use this test along with `rake pact:verify:foobar` to debug end to end issues.
# The Bar app is in spec/support/bar_pact_helper.rb

describe "Bar", :pact => true do

  it "can retrieve a thing"  do

      Pact.clear_configuration
      Pact.clear_consumer_world

      Pact.service_consumer "Foo" do
        has_pact_with "Bar" do
          mock_service :bar_service do
            pact_specification_version "2"
            port 4638
          end
        end
      end

      bar_service.
        upon_receiving("a retrieve thing request").with({
        method: :get,
        path: '/thing'
      }).
        will_respond_with({
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: Pact.each_like({status: Pact.term(/\d+/, "4")})
      })

      bar_response = Net::HTTP.get_response(URI('http://localhost:4638/thing'))

      expect(bar_response.code).to eql '200'
      expect(JSON.parse(bar_response.body)).to eq [{"status" => "4"}]

      puts bar_service.write_pact
  end

end