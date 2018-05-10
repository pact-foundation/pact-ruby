require 'pact/retry'

module Pact
  module Hal
    class HttpClient
      attr_accessor :username, :password

      def initialize options
        @username = options[:username]
        @password = options[:password]
      end

      def get href, params = {}
        uri = URI(href)
        perform_request(create_request(uri, 'Get'), uri)
      end

      def put href, body = nil
        uri = URI(href)
        perform_request(create_request(uri, 'Put', body), uri)
      end

      def post href, body = nil
        uri = URI(href)
        perform_request(create_request(uri, 'Post', body), uri)
      end

      def create_request uri, http_method, body = nil
        path = uri.path.size == 0 ? "/" : uri.path
        request = Net::HTTP.const_get(http_method).new(path)
        request['Content-Type'] = "application/json;charset=utf-8" if ['Post', 'Put', 'Patch'].include?(http_method)
        # The verifications resource didn't have the content_types_provided set, so publishing fails if we don't have */*
        request['Accept'] = "application/hal+json, */*"
        request.body = body if body
        request.basic_auth username, password if username
        request
      end

      def perform_request request, uri
        options = {:use_ssl => uri.scheme == 'https'}
        response = Retry.until_true do
          Net::HTTP.start(uri.host, uri.port, :ENV, options) do |http|
            http.request request
          end
        end
        Response.new(response)
      end

      class Response < SimpleDelegator
        def body
          bod = __getobj__().body
          if bod && bod != ''
            JSON.parse(bod)
          else
            nil
          end
        end

        def success?
          __getobj__().code.start_with?("2")
        end
      end
    end
  end
end
