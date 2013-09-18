require 'pact/consumer/mock_service/rack_request_helper'

module Pact
  module Consumer

    class InteractionDelete

      include RackRequestHelper

      def initialize name, logger, interaction_list
        @name = name
        @logger = logger
        @interaction_list = interaction_list
      end

      def match? env
        env['REQUEST_PATH'].start_with?('/interactions') &&
          env['REQUEST_METHOD'] == 'DELETE'
      end

      def respond env
        @interaction_list.clear
        @logger.info "Cleared interactions before example \"#{params_hash(env)['example_description']}\""
        [200, {}, ['Deleted interactions']]
      end
    end
  end
end