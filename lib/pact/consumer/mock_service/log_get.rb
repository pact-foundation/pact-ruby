module Pact
  module Consumer
    class LogGet

      include RackRequestHelper

      def initialize name, logger
        @name = name
        @logger = logger
      end

      def match? env
        headers_from(env)['X-Pact'] &&
        env['REQUEST_PATH'].start_with?('/log') &&
          env['REQUEST_METHOD'] == 'GET'
      end

      def respond env
        @logger.info "Log message from client - #{message(env)}"
        [200, {}, []]
      end

      def message env
        params_hash(env)['msg']
      end
    end
  end
end
