module Pact
  module Request

    class Base

      attr_reader :method, :path, :headers, :body

      def self.from_hash(hash)
        sym_hash = hash.inject({}) { |memo, (k,v)| memo[k.to_sym] = v; memo }
        method = sym_hash.fetch(:method)
        path = sym_hash.fetch(:path)
        headers = sym_hash.fetch(:headers, nil)
        body = sym_hash.fetch(:body, nil)
        new(method, path, headers, body)
      end

      def initialize(method, path, headers, body)
        @method = method.to_s
        @path = path.chomp('/')
        @headers = headers
        @body = body
      end

      def empty_body?
        if body.nil? || body == ''
          true
        else
          false
        end
      end

      def to_json(options = {})
        as_json.to_json(options)
      end

      def as_json
        base_json = {
          method: method,
          path: path,
        }

        base_json.merge!(body: body) if body
        base_json.merge!(headers: headers) if headers
        base_json
      end

    end

    class Expected < Base

      def match(actual_request)
        matches_route?(actual_request) && matches_body?(actual_request)
      end

      def matches_route?(actual_request)
        (method == actual_request.method) && (path == actual_request.path)
      end

      private

      def matches_body?(actual_request)
        return true if empty_body? && actual_request.empty_body?
        return false if actual_request.empty_body?
        recursively_matches?(body, actual_request.body)
      end

      def recursively_matches?(expected, actual)
        if expected.respond_to? :to_hash
          expected.to_hash.all? do |key, value|
            recursively_matches?(value, actual[key])
          end
        elsif expected.respond_to? :to_a
          ok = true
          expected.to_a.each_with_index do |value, key|
            ok = false unless recursively_matches?(value, actual[key])
          end
          ok
        elsif expected.respond_to? :match
          expected.match actual
        else
          expected == actual
        end
      end

    end

    class Actual < Base
    end

  end
end
