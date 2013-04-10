module Pact
  module Request

    class Base

      attr_reader :method, :path, :body

      def self.from_hash(hash)
        sym_hash = hash.inject({}) { |memo, (k,v)| memo[k.to_sym] = v; memo }
        method = sym_hash.fetch(:method)
        path = sym_hash.fetch(:path)
        body = sym_hash.fetch(:body, nil)
        new(method, path, body)
      end

      def initialize(method, path, body)
        @method = method.to_s
        @path = path.chomp('/')
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
        base_json
      end

    end

    class Expected < Base

      def matches?(actual_request)
        return false if method != actual_request.method
        return false if path != actual_request.path
        return true if empty_body? && actual_request.empty_body?
        return false if actual_request.empty_body?
        recursively_matches?(body, actual_request.body)
      end

      private

      def recursively_matches?(expected, actual)
        if expected.respond_to? :all?
          expected.all? do |key, value|
            recursively_matches?(value, actual[key])
          end
        elsif expected.respond_to? :matches?
          expected.matches? actual
        else
          expected == actual
        end
      end

    end

    class Actual < Base
    end

  end
end
