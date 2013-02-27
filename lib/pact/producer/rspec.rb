require 'json' 
require 'json/add/core'
require 'rack/test'

module Pact
  module Producer
    module RSpec

      def self.included(base)
        puts 'included'
      end

      def honour_pactfile pactfile
        honour_pact JSON.load(File.read(pactfile))
      end

      def honour_pact pact
        pact.each do |interaction|
          request, response = interaction['request'], interaction['response']
          response = interaction['response']

          describe interaction['description'] do
            before do
              self.send(request['method'], request['path'])
            end
            if response['status']
              it "has status code #{response['status']}" do
                expect(last_response.status).to eql response['status']
              end
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
            if response['body']
              it "body" do
                expect(last_response.body).to match response['body']
              end
            end
          end

        end
      end

    end
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.extend Pact::Producer::RSpec
end
