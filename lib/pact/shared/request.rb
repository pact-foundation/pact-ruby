require 'pact/matchers'
require 'pact/symbolize_keys'
require 'pact/consumer_contract/headers'

module Pact

  module Request

    class Base
      include Pact::Matchers
      include Pact::SymbolizeKeys
      extend Pact::Matchers

      attr_reader :method, :path, :headers, :body, :query, :options

      def initialize(method, path, headers, body, query)
        @method = method.to_s
        @path = path.chomp('/')
        @headers = Hash === headers ? Headers.new(headers) : headers # Could be a NullExpectation - TODO make this more elegant
        @body = body
        @query = query
      end

      def to_json(options = {})
        as_json.to_json(options)
      end

      def as_json options = {}
        to_hash
      end

      def to_hash
        hash = {
          method: method,
          path: path,
        }

        hash.merge!(query: query) unless query.is_a? self.class.key_not_found.class
        hash.merge!(headers: headers) unless headers.is_a? self.class.key_not_found.class
        hash.merge!(body: body) unless body.is_a? self.class.key_not_found.class
        hash
      end

      def method_and_path
        "#{method.upcase} #{full_path}"
      end

      def full_path
        display_path + display_query
      end

      def content_type
        return nil if headers.is_a? self.class.key_not_found.class
        headers['Content-Type']
      end

      protected

      def self.key_not_found
        raise NotImplementedError
      end

      def to_hash_without_body
        keep_keys = [:method, :path, :headers, :query]
        as_json.reject{ |key, value| !keep_keys.include? key }
      end

      def display_path
        path.empty? ? "/" : path
      end

      def display_query
        (query.nil? || query.empty?) ? '' : "?#{Pact::Reification.from_term(query)}"
      end

    end
  end
end