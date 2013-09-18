module Pact
  module Consumer

    class StartupPoll

      def initialize name, logger
        @name = name
        @logger = logger
      end

      def match? env
        env['REQUEST_PATH'] == '/index.html' &&
          env['REQUEST_METHOD'] == 'GET'
      end

      def respond env
        @logger.info "#{@name} started up"
        [200, {}, ['Started up fine']]
      end
    end
  end
end