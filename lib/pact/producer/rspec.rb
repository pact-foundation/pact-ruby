require 'json'
require 'json/add/core'
require 'rack/test'
require 'pact/producer'
require 'pact/reification'

module Pact
  module Producer
    module RSpec

      def honour_pactfile pactfile
        honour_pact JSON.load(File.read(pactfile))
      end

      def honour_pact pact
        pact.each do |interaction|
          request = interaction['request']
          response = interaction['response']

          describe "#{interaction['description']} to '#{request['path']}'" do
            before do
              args = [request['path']]

              body = request['body']
              if body
                body = JSON.dump(Pact::Reification.from_term(body))
              else
                body = ""
              end

              args << body

              if request['headers']
                request_headers = {}
                request['headers'].each do |key, value|
                  key = key.upcase
                  if key.match /CONTENT.TYPE/
                    request_headers['CONTENT_TYPE'] = value
                  else
                    request_headers['HTTP_' + key.to_s] = value
                  end
                end
                args << request_headers
              end
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
                expect(parse_entity_from_response(last_response)).to match_term response['body']
              end
            end
          end

        end

      end

      module TestMethods
        def parse_entity_from_response response
          case response.headers['Content-Type']
          when 'application/json'
            JSON.load(response.body)
          else
            response.body
          end
        end
      end


    end
  end
end

RSpec::Matchers.define :match_term do |expected|
  match do |actual|
    case
    when expected.is_a?(Regexp)
      actual =~ expected
    when expected.is_a?(Pact::Term)
      expect(actual).to match_term expected.matcher
    when expected.is_a?(Array)
      if actual.is_a?(Array)
        expected.each_with_index do |value, index|
          expect(actual[index]).to match_term value
        end
        true
      else
        false
      end
    when expected.is_a?(Hash)
      if actual.is_a?(Hash)
        expected.each do |key, value|
          expect(actual[key]).to match_term value
        end
        true
      else
        false
      end
    else
      actual == expected
    end
  end
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Pact::Producer::RSpec::TestMethods
  config.extend Pact::Producer::RSpec
end
