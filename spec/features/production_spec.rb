require 'pact/producer/rspec'

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
                "body": "Donut created.",
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
                    "json_class": "Regexp",
                    "o": 0,
                    "s": "deleted"
                },
                "status": 204
            }
        }
    ]
    EOS

    honour_pact pact

  end
end
