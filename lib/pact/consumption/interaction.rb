require 'digest/sha1'
require 'json'
require 'net/http'
require_relative 'response'

module Pact
  module Consumption
    class Interaction

      # TODO: should not need to expose this, but a test uses it atm
      attr_reader :response

      def initialize(producer, request)
        @producer = producer
        @request = request
      end

      def will_respond_with(response)
        @response = Response.new(response)
        http = Net::HTTP.new(@producer.uri.host, @producer.uri.port)
        http.request_post('/interactions', reify.to_json)
        write_pact
        @producer
      end

      def write_pact
        File.open(File.join(@producer.pact_path, "#{fingerprint}.json"), 'w') do |f|
          f.write serialize
        end
      end

      private

      def reify
        {
          :request => @request,
          :response => @response.reify
        }
      end

      def to_json
        {
          :request => @request,
          :response => @response.to_json
        }
      end

      def fingerprint
        Digest::SHA1.hexdigest serialize
      end

      def serialize
        JSON.dump(to_json)
      end

    end
  end
end
