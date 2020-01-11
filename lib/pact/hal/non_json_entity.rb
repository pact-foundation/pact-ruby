module Pact
  module Hal
    class NonJsonEntity
      def initialize(href, body, http_client, response = nil)
        @href = href
        @body = body
        @client = http_client
        @response = response
      end

      def success?
        true
      end

      def response
        @response
      end

      def body
        @body
      end

      def assert_success!
        self
      end
    end
  end
end
