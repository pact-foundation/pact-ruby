require 'json'
require 'json/add/core'
require 'rack/test'
require 'pact/producer'
require 'pact/reification'

module Pact
  module Producer
    module RSpec

      def honour_pactfile pactfile, options = {}
        honour_pact JSON.load(File.read(pactfile)), options
      end

      def honour_pact pact, options = {}
        load_fixtures options[:fixtures_dir]

        pact.each do |interaction|
          request = interaction['request']
          response = interaction['response']
          description = "#{interaction['description']} to '#{request['path']}'"
          description << " using fixture '#{interaction['fixture_name']}'" if interaction['fixture_name']

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

              load_fixture options[:fixtures_dir], interaction['fixture_name']

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
            after_pact_fixture interaction['fixture_name']
          end

        end

      end

      def load_fixtures fixtures_dir
        if fixtures_dir
          #puts $:
          Dir[File.join(fixtures_dir, '**/*.rb')].each do |src_file|
            puts "requiring #{src_file}"
            #require src_file
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

        def camelize(str)
          str.split('_').map {|w| w.capitalize}.join
        end

        def after_pact_fixture fixture_name
          if fixture_name
            fixture_class = Object.const_get(camelize(fixture_name)).new
            fixture_class.tear_down
          end
        end

        def load_fixture fixtures_dir, fixture_name
          if fixture_name
            fixture_class = Object.const_get(camelize(fixture_name)).new
            fixture_class.set_up
            # raise "Please specify a fixtures directory for the fixture \"#{fixture_name}\" by specifying a :fixtures_dir in the options" unless fixtures_dir
            # file_path = Pathname.new(fixtures_dir) + (fixture_name + ".rb")
            # load file_path
          end
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
