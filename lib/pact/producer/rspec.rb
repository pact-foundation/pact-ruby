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
              path = request['path']
              query = request['query']
              if query && !query.empty?
                path += "?" + request['query']
              end

              args = [path]

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
                  if key.match(/CONTENT.TYPE/)
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

  def matching? actual, expected, desc = nil, parent = nil
    mismatch = {actual: actual, expected: expected, desc: desc, parent: parent}
    case
    when expected.is_a?(Regexp)
      match_regex actual, expected, mismatch
    when expected.is_a?(Pact::Term)
      match_term actual, expected
    when expected.is_a?(Array)
      match_array actual, expected, mismatch
    when expected.is_a?(Hash)
      match_hash actual, expected, mismatch
    else
      match_object actual, expected, mismatch
    end
    true
  end

  def match_object actual, expected, mismatch
    throw :mismatch, mismatch unless actual == expected
  end

  def match_regex actual, expected, mismatch
    throw :mismatch, mismatch unless actual =~ expected
  end

  def match_term actual, expected
    matching? actual, expected.matcher
  end

  def match_hash actual, expected, mismatch
    if actual.is_a?(Hash)
      expected.each do |key, value|
        matching? actual[key], value, "key '#{key}'", actual
      end
    else
      throw :mismatch, mismatch
    end
  end

  def match_array actual, expected, mismatch
    if actual.is_a?(Array)
      expected.each_with_index do |value, index|
        matching? actual[index], value, "index #{index}", actual
      end
    else
      throw :mismatch, mismatch
    end
  end


  match do |actual|
    @message = catch(:mismatch) do
      matching? actual, expected
    end
    puts "MESSAGE #{@message}"
    @message == true
  end

  def mismatch_message
    message = " Expected '#{@message[:actual]}' to equal '#{@message[:expected]}'"
    message << " at #{@message[:desc]}" if @message[:desc]
    message << " of #{@message[:parent]}" if @message[:parent]
    message
  end

  failure_message_for_should do | actual |
    mismatch_message
  end

end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Pact::Producer::RSpec::TestMethods
  config.extend Pact::Producer::RSpec
end
