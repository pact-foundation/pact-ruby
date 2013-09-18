require 'pact/matchers'
require 'pact/symbolize_keys'

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

        base_json.merge!(body: body) unless body.is_a? self.class.key_not_found.class
        base_json.merge!(headers: headers) unless headers.is_a? self.class.key_not_found.class
        base_json.merge!(query: query) unless query.is_a? self.class.key_not_found.class
        base_json
      end

      def method_and_path
        "#{method.upcase} #{path}"
      end

      def full_path
        fp = ''
        if path.empty?
          fp << "/"
        else
          fp << path
        end
        if query && !query.empty?
          fp << ("?" + (query.kind_of?(Pact::Term) ? query.generate : query))
        end
        fp
      end

      protected

      def self.key_not_found
        raise NotImplementedError
      end      

      def as_json_without_body
        keep_keys = [:method, :path, :headers, :query]
        as_json.reject{ |key, value| !keep_keys.include? key }
      end
    end
  end
end