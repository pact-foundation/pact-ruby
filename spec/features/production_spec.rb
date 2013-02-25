require 'json'
require 'json/add/core'
require 'rack/test'

class ServiceUnderTest

  def call(env)
    case env['PATH_INFO']
    when '/donuts'
      [201, {'Content-Type' => 'text/html'}, "Donut created."]
    when '/charlie'
      [204, {'Content-Type' => 'text/html'}, "Your charlie has been deleted"]
    end
  end

end

module Pact::Producer
  describe "A service production side of a pact" do
    include Rack::Test::Methods

    def app
      ServiceUnderTest.new
    end

    PACTS_PATH = File.expand_path('../../pacts', __FILE__)

    pact = JSON.parse <<-EOS
[
    {
        "request": {
            "method": {
                "json_class": "Symbol", 
                "s": "post"
            }, 
            "path": "/donuts"
        }, 
        "response": {
            "body": "Donut created.", 
            "status": 201
        }
    }, 
    {
        "request": {
            "method": {
                "json_class": "Symbol", 
                "s": "delete"
            }, 
            "path": "/charlie"
        }, 
        "response": {
            "body": {
                "json_class": "Regexp", 
                "o": 0, 
                "s": "deleted"
            }, 
            "status": 204
        }
    }
]
EOS

    pact.each do |interaction|
      request, response = interaction['request'], interaction['response']
      response = interaction['response']

      describe "matching response" do
        before do
          self.send(request['method'], request['path'])
        end
        it "has status code #{response['status']}" do
          expect(last_response.status).to eql response['status']
        end
        if response['headers']
          describe "headers" do
            response['headers'].each do |name, value|
              it "#{name} is #{value}" do
                expect(last_response.headers[name]).to match value
              end
            end
          end
        end
        it "body" do
          expect(last_response.body).to match response['body']
        end
      end

    end
  end
end
