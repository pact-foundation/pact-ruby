require 'uri'
require 'delegate'
require 'pact/hal/link'

module Pact
  module Hal
    class Entity
      def initialize(data, http_client, response = nil)
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

      def _link(key)
        if @links[key]
          Link.new(@links[key], @client)
        else
          nil
        end
      end

      def success?
        true
      end

      def response
        @response
      end

      def fetch(key)
        @links[key]
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
    end

    class ErrorEntity < Entity
      def success?
        false
      end
    end
  end
end
