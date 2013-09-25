require 'pact/consumer/mock_service/mock_service_administration_endpoint'

module Pact
  module Consumer
    class LogGet < MockServiceAdministrationEndpoint

      include RackRequestHelper

      def request_path
        '/log'
      end

      def request_method
        'GET'
      end


      def respond env
        logger.info "Debug message from client - #{message(env)}"
        [200, {}, []]
      end

      def message env
        params_hash(env)['msg']
      end
    end
  end
end
