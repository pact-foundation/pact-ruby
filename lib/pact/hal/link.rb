require 'erb'
require 'delegate'

module Pact
  module Hal
    class Link
      attr_reader :request_method, :href

      DEFAULT_GET_HEADERS = {
        "Accept" => "application/hal+json"
      }.freeze

      DEFAULT_POST_HEADERS = {
        "Accept" => "application/hal+json",
        "Content-Type" => "application/json"
      }.freeze

      def initialize(attrs, http_client)
        @attrs = attrs
        @request_method = attrs.fetch(:method, :get).to_sym
        @href = attrs.fetch('href')
        @http_client = http_client
      end

      def run(payload = nil)
        case request_method
        when :get
          get(payload)
        when :put
          put(payload)
        when :post
          post(payload)
        end
      end

      def title_or_name
        title || name
      end

      def title
        @attrs['title']
      end

      def name
        @attrs['name']
      end

      def get(payload = {}, headers = {})
        wrap_response(href, @http_client.get(href, payload, DEFAULT_GET_HEADERS.merge(headers)))
      end

      def get!(*args)
        get(*args).assert_success!
      end

      def put(payload = nil, headers = {})
        wrap_response(href, @http_client.put(href, payload ? payload.to_json : nil, DEFAULT_POST_HEADERS.merge(headers)))
      end

      def post(payload = nil, headers = {})
        wrap_response(href, @http_client.post(href, payload ? payload.to_json : nil, DEFAULT_POST_HEADERS.merge(headers)))
      end

      def post!(payload = nil, headers = {})
        post(payload, headers).assert_success!
      end

      def expand(params)
        expanded_url = expand_url(params, href)
        new_attrs = @attrs.merge('href' => expanded_url)
        Link.new(new_attrs, http_client)
      end

      def with_query(query)
        if query && query.any?
          uri = URI(href)
          existing_query_params = Rack::Utils.parse_nested_query(uri.query)
          uri.query = Rack::Utils.build_nested_query(existing_query_params.merge(query))
          new_attrs = attrs.merge('href' => uri.to_s)
          Link.new(new_attrs, http_client)
        else
          self
        end
      end

      private

      attr_reader :attrs, :http_client

      def wrap_response(href, http_response)
        require 'pact/hal/entity' # avoid circular reference
        require 'pact/hal/non_json_entity'

        if http_response.success?
          if http_response.json?
            Entity.new(href, http_response.body, @http_client, http_response)
          else
            NonJsonEntity.new(href, http_response.raw_body, @http_client, http_response)
          end
        else
          ErrorEntity.new(href, http_response.raw_body, @http_client, http_response)
        end
      end

      def expand_url(params, url)
        params.inject(url) do | url, (key, value) |
          url.gsub('{' + key.to_s + '}', ERB::Util.url_encode(value))
        end
      end
    end
  end
end
