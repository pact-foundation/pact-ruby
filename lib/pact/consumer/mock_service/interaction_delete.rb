require 'pact/consumer/mock_service/rack_request_helper'
require 'pact/consumer/mock_service/mock_service_administration_endpoint'

module Pact
  module Consumer

    class InteractionDelete < MockServiceAdministrationEndpoint

      include RackRequestHelper

      attr_accessor :interaction_list

      def initialize name, logger, interaction_list
        super name, logger
        @interaction_list = interaction_list
      end

      def request_path
        '/interactions'
      end

      def request_method
        'DELETE'
      end

      def respond env
        interaction_list.clear
        logger.info "Cleared interactions before example \"#{params_hash(env)['example_description']}\""
        [200, {}, ['Deleted interactions']]
      end
    end
  end
end