require 'pact/consumer/mock_service/mock_service_administration_endpoint'

module Pact
  module Consumer

    class MissingInteractionsGet < MockServiceAdministrationEndpoint
      include RackRequestHelper

      def initialize name, logger, interaction_list
        super name, logger
        @interaction_list = interaction_list
      end

      def request_path
        '/number_of_missing_interactions'
      end

      def request_method
        'GET'
      end

      def respond env
        number_of_missing_interactions = @interaction_list.missing_interactions.size
        logger.info "Number of missing interactions for mock \"#{name}\" = #{number_of_missing_interactions}"
        [200, {}, ["#{number_of_missing_interactions}"]]
      end

    end
  end
end