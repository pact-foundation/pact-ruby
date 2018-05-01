require 'uri'
require 'delegate'

module Pact
  module Hal
    class Link
      attr_reader :request_method, :href

      def initialize(attrs, http_client)
        @attrs = attrs
        @request_method = attrs.fetch(:method, :get).to_sym
        @href = attrs.fetch('href')
        @http_client = http_client
      end

      def run(payload = nil)
        response = case request_method
          when :get
            get(payload)
          when :put
            put(payload)
          when :post
            post(payload)
          end
      end

      def get(payload = {})
        wrap_response(@http_client.get(href, payload))
      end

      def put(payload = nil)
        wrap_response(@http_client.put(href, payload ? JSON.dump(payload) : nil))
      end

      def post(payload = nil)
        wrap_response(@http_client.post(href, payload ? JSON.dump(payload) : nil))
      end

      def expand(params)
        expanded_url = expand_url(params, href)
        new_attrs = @attrs.merge('href' => expanded_url)
        Link.new(new_attrs, @http_client)
      end

      private

      def wrap_response(http_response)
        require 'pact/hal/entity' # avoid circular reference
        if http_response.success?
          Entity.new(http_response.body, @http_client, http_response)
        else
          ErrorEntity.new(http_response.body, @http_client, http_response)
        end
      end

      def expand_url(params, url)
        new_url = url
        params.each do | key, value |
          new_url = new_url.gsub('{' + key.to_s + '}', value)
        end
        new_url
      end
    end
  end
end
