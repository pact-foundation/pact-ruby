require 'pact/shared/request'
require 'pact/shared/null_expectation'

module Pact

  module Request

    class Expected < Pact::Request::Base

      DEFAULT_OPTIONS = {:allow_unexpected_keys => false}.freeze
      attr_accessor :options #Temporary hack

      def self.from_hash(hash)
        sym_hash = symbolize_keys hash
        method = sym_hash.fetch(:method)
        path = sym_hash.fetch(:path)
        query = sym_hash.fetch(:query, key_not_found)
        headers = sym_hash.fetch(:headers, key_not_found)
        body = sym_hash.fetch(:body, key_not_found)
        options = sym_hash.fetch(:options, {})
        new(method, path, headers, body, query, options)
      end

      def initialize(method, path, headers, body, query, options = {})
        super(method, path, headers, body, process_query(query))
        @options = options
      end

      def matches?(actual_request)
        difference(actual_request).empty?
      end

      def matches_route? actual_request
        diff({:method => method, :path => path}, {:method => actual_request.method, :path => actual_request.path}).empty?
      end

      def difference(actual_request)
        request_diff = diff(to_hash_without(:body, :query), actual_request.to_hash_without(:body, :query))
        request_diff = request_diff.merge(query_difference(actual_request.query))
        request_diff.merge(body_difference(actual_request.body))
      end

      protected

      def self.key_not_found
        Pact::NullExpectation.new
      end

      private

      # Options is a dirty hack to allow Condor to send extra keys in the request,
      # as it's too much work to set up an exactly matching expectation.
      # Need to implement a proper matching strategy and remove this.
      # Do not rely on it!
      def runtime_options
        DEFAULT_OPTIONS.merge(symbolize_keys(options))
      end

      def body_difference(actual_body)
        return {} if body.is_a? NullExpectation

        diff({body: body}, {body: actual_body}, allow_unexpected_keys: runtime_options[:allow_unexpected_keys_in_body])
      end

      def query_difference(actual_query)
        return {} if query.is_a? NullExpectation

        diff({query: query}, {query: actual_query})
      end

      def process_query(query)
        if query.is_a?(Hash)
          Pact::HashQuery.new(query)
        else
          query
        end
      end
    end

  end
end
