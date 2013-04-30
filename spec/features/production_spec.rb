require 'pact/producer/rspec'

class ServiceUnderTest

  def call(env)
    case env['PATH_INFO']
    when '/donuts'
      [201, {'Content-Type' => 'application/json'}, { message: "Donut created." }.to_json]
    when '/charlie'
      [200, {'Content-Type' => 'application/json'}, { message: "Your charlie has been deleted" }.to_json]
    end
  end

end

module Pact::Producer

  describe "A service production side of a pact" do

    def app
      ServiceUnderTest.new
    end

    pact = JSON.parse <<-EOS
    [
        {
            "description": "donut creation request",
            "request": {
                "method": {
                    "json_class": "Symbol",
                    "s": "post"
                },
                "path": "/donuts"
            },
            "response": {
                "body": {"message": "Donut created."},
                "status": 201
            }
        },
        {
            "description": "charlie deletion request",
            "request": {
                "method": {
                    "json_class": "Symbol",
                    "s": "delete"
                },
                "path": "/charlie"
            },
            "response": {
                "body": {
                  "message": {
                    "json_class": "Regexp",
                    "o": 0,
                    "s": "deleted"
                  }
                },
                "status": 200
            }
        }
    ]
    EOS

    honour_pact pact

  end
end
