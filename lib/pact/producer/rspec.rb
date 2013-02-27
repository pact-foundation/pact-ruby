require 'json' 
require 'json/add/core'
require 'rack/test'
require 'pact/producer'

module Pact
  module Producer
    module RSpec

      def honour_pactfile pactfile
        honour_pact JSON.load(File.read(pactfile))
      end

      def honour_pact pact
        pact.each do |interaction|
          request, response = interaction['request'], interaction['response']
          response = interaction['response']

          describe "#{interaction['description']} to '#{request['path']}'" do
            before do
              args = [ request['path'] ]
              args << JSON.dump(request['body']) if request['body']
              self.send(request['method'], *args)
            end
            if response['status']
              it "has status code #{response['status']}" do
                expect(last_response.status).to eql response['status']
              end
            end
            if response['headers']
              describe "includes headers" do
                response['headers'].each do |name, value|
                  it "#{name} is #{value}" do
                    expect(last_response.headers[name]).to match_term value
                  end
                end
              end
            end
            if response['body']
              it "has matching body" do
                expect(JSON.load(last_response.body)).to match_term response['body']
              end
            end
          end

        end
      end

    end
  end
end

RSpec::Matchers.define :match_term do |expected|
  match do |actual|
    case 
      when expected.is_a?(Hash)
        actual
        expected.each do |key, value|
          expect(actual[key]).to match_term expected[key]
        end
        true
      when expected.is_a?(Regexp)
        actual =~ expected
      when expected.is_a?(Pact::Term)
        expect(actual).to match_term expected.match
      else
        actual == expected
    end
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.extend Pact::Producer::RSpec
end
