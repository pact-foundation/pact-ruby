require 'pact/consumer/mock_service/rack_request_helper'
require 'pact/consumer/mock_service/mock_service_administration_endpoint'

module Pact
  module Consumer

    class SetUpMockService < MockServiceAdministrationEndpoint

      def call env
        RequestHandler.new(env).call
      end

      def request_path
        '/mock-services'
      end

      def request_method
        'POST'
      end

      class RequestHandler

        include RackRequestHelper

        attr_reader :env

        def initialize env
          @env = env
        end

        def call
          # TODO fix this
          # TODO work out how to log to a helpful file
          Pact::Consumer::AppManager.instance.spawn_all
          Pact::Consumer::AppManager.instance.register_mock_service_for "unknown", mock_service_uri

          [204, {'Location' => "#{resource_uri}/#{port}", 'Pact-Mock-Service-Location' => mock_service_uri}, []]
        end

        def port
          params_hash(env).fetch('port')
        end

        def mock_service_uri
          "http://localhost:#{port}"
        end

        def resource_uri
          env["rack.url_scheme"] + "://" + env['SERVER_NAME'] + ':' + env['SERVER_PORT'] + env['PATH_INFO']
        end

      end
    end
  end
end