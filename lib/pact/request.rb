require 'pact/matchers'

module Pact

  module Request

    class NullExpectation
      def to_s
        "<No expectation>"
      end

      def ==(other_object)
       other_object.is_a? NullExpectation
      end

      def ===(other_object)
       other_object.is_a? NullExpectation
      end

      def eql?(other_object)
        self == other_object
      end

      def hash
        2934820948209428748274238642672
      end
    end

    class Base
    include Pact::Matchers
    extend Pact::Matchers

    NULL_EXPECTATION = NullExpectation.new

      attr_reader :method, :path, :headers, :body, :query

      def self.from_hash(hash)
        sym_hash = hash.inject({}) { |memo, (k,v)| memo[k.to_sym] = v; memo }
        method = sym_hash.fetch(:method)
        path = sym_hash.fetch(:path)
        query = sym_hash.fetch(:query, NULL_EXPECTATION)
        headers = sym_hash.fetch(:headers, NULL_EXPECTATION)
        body = sym_hash.fetch(:body, NULL_EXPECTATION)
        new(method, path, headers, body, query)
      end

      def initialize(method, path, headers, body, query)
        @method = method.to_s
        @path = path.chomp('/')
        @headers = headers
        @body = body
        @query = query
      end

      def to_json(options = {})
        as_json.to_json(options)
      end

      def as_json
        base_json = {
          method: method,
          path: path,
        }

        base_json.merge!(body: body) unless body.is_a? NullExpectation
        base_json.merge!(headers: headers) unless headers.is_a? NullExpectation
        base_json.merge!(query: query) unless query.is_a? NullExpectation
        base_json
      end

    end

    class Expected < Base

      def match(actual_request)
        difference(actual_request).empty?
      end

      def matches_route? actual_request
        diff({:method => method, :path => path}, {:method => actual_request.method, :path => actual_request.path}).empty?
      end

      def difference(actual_request)
        diff(as_json, actual_request.as_json)
      end

    end

    class Actual < Base
    end

  end
end
