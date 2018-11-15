require 'uri'
require 'delegate'
require 'pact/hal/link'
require 'pact/errors'

module Pact
  module Hal
    class RelationNotFoundError < ::Pact::Error; end

    class ErrorResponseReturned < ::Pact::Error; end

    class Entity

      def initialize(href, data, http_client, response = nil)
        @href = href
        @data = data
        @links = (@data || {}).fetch("_links", {})
        @client = http_client
        @response = response
      end

      def get(key, *args)
        _link(key).get(*args)
      end

      def post(key, *args)
        _link(key).post(*args)
      end

      def put(key, *args)
        _link(key).put(*args)
      end

      def can?(key)
        @links.key? key.to_s
      end

      def follow(key, http_method, *args)
        Link.new(@links[key].merge(method: http_method), @client).run(*args)
      end

      def _link(key, fallback_key = nil)
        if @links[key]
          Link.new(@links[key], @client)
        elsif fallback_key && @links[fallback_key]
          Link.new(@links[fallback_key], @client)
        else
          nil
        end
      end

      def _link!(key)
        _link(key) or raise RelationNotFoundError.new("Could not find relation '#{key}' in resource at #{@href}")
      end

      def success?
        true
      end

      def response
        @response
      end

      def fetch(key, fallback_key = nil)
        @links[key] || (fallback_key && @links[fallback_key])
      end

      def method_missing(method_name, *args, &block)
        if @data.key?(method_name.to_s)
          @data[method_name.to_s]
        elsif @links.key?(method_name)
          Link.new(@links[method_name], @client).run(*args)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        @data.key?(method_name) || @links.key?(method_name)
      end

      def assert_success!
        self
      end
    end

    class ErrorEntity < Entity

      def initialize(href, data, http_client, response = nil)
        @href = href
        @data = data
        @links = {}
        @client = http_client
        @response = response
      end

      def success?
        false
      end

      def assert_success!
        raise ErrorResponseReturned.new("Error retrieving #{@href} status=#{response ? response.code: nil} #{response ? response.raw_body : ''}")
      end
    end
  end
end
