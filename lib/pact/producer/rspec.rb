require 'json'
require 'json/add/core'
require 'rack/test'
require 'pact/producer'
require 'pact/reification'
require 'pact/producer/producer_state'
require 'pact/json_warning'

module Pact
  module Producer
    module RSpec

      include Pact::JsonWarning

      def honour_pactfile pactfile, options = {}
        consumer_contract = Pact::ConsumerContract.from_json(File.read(pactfile))
        honour_pact consumer_contract.interactions, options
      end

      def honour_pact interactions, options = {}

        check_for_active_support_json

        interactions.each do |interaction|
          request = interaction['request']
          response = interaction['response']
          description = "#{interaction['description']} to '#{request['path']}'"
          description << " given #{interaction['producer_state']}" if interaction['producer_state']

          describe description  do
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

              set_up_producer_state interaction['producer_state'], options[:consumer]

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

          after do
            tear_down_producer_state interaction['producer_state'], options[:consumer]
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

        def set_up_producer_state producer_state_name, consumer
          if producer_state_name
            get_producer_state(producer_state_name, consumer).set_up
          end
        end

        def tear_down_producer_state producer_state_name, consumer
          if producer_state_name
            get_producer_state(producer_state_name, consumer).tear_down
          end
        end

        private

        def get_producer_state producer_state_name, consumer
          unless producer_state = ProducerState.get(producer_state_name, :for => consumer)
            extra = consumer ? " for consumer \"#{consumer}\"" : ""
            raise "Could not find a producer state defined for \"#{producer_state_name}\"#{extra}. Have you required the producer state file in your spec?"
          end
          producer_state
        end
      end
    end
  end
end

RSpec::Matchers.define :match_term do |expected|

  def matching? actual, expected, desc = nil, parent = nil
    mismatch = {actual: actual, expected: expected, desc: desc, parent: parent}
    case expected
    when *[Array, Hash, Regexp]
      send("match_#{expected.class.name.downcase}", actual, expected, mismatch)
    when Pact::Term
      match_term actual, expected
    else
      match_object actual, expected, mismatch
    end
    true
  end

  def match_object actual, expected, mismatch
    throw :mismatch, mismatch unless actual == expected
  end

  def match_regexp actual, expected, mismatch
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
    @message == true
  end

  def mismatch_message
    actual = @message[:actual].nil? ? 'nil' : "\"#{@message[:actual]}\""
    expected = @message[:expected].nil? ? 'nil' : "\"#{@message[:expected]}\""
    message = " Expected #{actual} to match #{expected}"
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
