require 'pact/consumer/mock_service/rack_request_helper'
module Pact
  module Consumer
    class MockServiceAdministrationEndpoint

      attr_accessor :logger, :name

      def initialize name, logger
        @name = name
        @logger = logger
      end

      include RackRequestHelper

      def match? env
        headers_from(env)['X-Pact-Mock-Service'] &&
        env['REQUEST_PATH'] == request_path &&
          env['REQUEST_METHOD'] == request_method
      end

      def request_path
        raise NotImplementedError
      end

      def request_method
        raise NotImplementedError
      end

    end
  end
end