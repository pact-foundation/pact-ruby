require 'pact/matchers'
require 'pact/reification'
require 'pact/symbolize_keys'

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

      def empty?
        true
      end

      def nil?
        true
      end
    end

    class Replayable

      def initialize expected_request
        @expected_request = expected_request
      end

      def method
        expected_request.method
      end

      def path
        expected_request.full_path
      end

      def body
        case expected_request.body
        when String then expected_request.body
        when NullExpectation then ''
        else
          reified_body
        end
      end

      def headers
        request_headers = {}
        return request_headers if expected_request.headers.is_a?(NullExpectation)
        expected_request.headers.each do |key, value|
          key = key.upcase
          if key.match(/CONTENT.TYPE/)
            request_headers['CONTENT_TYPE'] = value
          else
            request_headers['HTTP_' + key.to_s] = value
          end
        end
        request_headers
      end

      private
      attr_reader :expected_request

      def reified_body
        rb = Pact::Reification.from_term(expected_request.body)
        if rb.is_a?(String)
          rb
        else
          JSON.dump(rb)
        end
      end
    end

    class Base
      include Pact::Matchers
      include Pact::SymbolizeKeys
      extend Pact::Matchers

      NULL_EXPECTATION = NullExpectation.new

      attr_reader :method, :path, :headers, :body, :query, :options

      def self.from_hash(hash)
        sym_hash = symbolize_keys hash
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

      def as_json_without_body
        keep_keys = [:method, :path, :headers, :query]
        as_json.reject{ |key, value| !keep_keys.include? key }
      end

      def short_description
        "#{method} #{full_path}"
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

    end

    class Expected < Base

      DEFAULT_OPTIONS = {:allow_unexpected_keys => false}.freeze
      attr_accessor :options

      def self.from_hash(hash)
        request = super
        request.options = symbolize_keys(hash).fetch(:options, {})
        request
      end

      def initialize(method, path, headers, body, query, options = {})
        super(method, path, headers, body, query)
        @options = options
      end

      def matches?(actual_request)
        difference(actual_request).empty?
      end

      def matches_route? actual_request
        diff({:method => method, :path => path}, {:method => actual_request.method, :path => actual_request.path}).empty?
      end

      def difference(actual_request)
        request_diff = diff(as_json_without_body, actual_request.as_json_without_body)
        unless body.is_a? NullExpectation
          request_diff.merge(body_difference(actual_request.body))
        else
          request_diff
        end
      end

      # Need to get rid of this...
      def as_json_with_options
        as_json.merge( options.empty? ? {} : { options: options} )
      end

      # Don't want to put the default options in the pact json just yet, so calculating these at run time, rather than assigning
      # the result to @options
      def runtime_options
        DEFAULT_OPTIONS.merge(symbolize_keys(options))
      end

      private

      def body_difference(actual_body)
        diff({:body => body}, {body: actual_body}, allow_unexpected_keys: runtime_options[:allow_unexpected_keys_in_body])
      end
    end

    class Actual < Base
    end

  end
end
