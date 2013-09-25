require 'pact/consumer/mock_service/mock_service_administration_endpoint'

module Pact
  module Consumer
    class VerificationGet < MockServiceAdministrationEndpoint

      include RackRequestHelper
      attr_accessor :interaction_list, :log_description

      def initialize name, logger, interaction_list, log_description
        super name, logger
        @interaction_list = interaction_list
        @log_description = log_description
      end

      def request_path
        '/verify'
      end

      def request_method
        'GET'
      end

      def respond env
        if interaction_list.all_matched?
          logger.info "Verifying - interactions matched for example \"#{example_description(env)}\""
          [200, {}, ['Interactions matched']]
        else
          logger.warn "Verifying - actual interactions do not match expected interactions for example \"#{example_description(env)}\". Interaction diffs:"
          logger.ap interaction_list.interaction_diffs, :warn
          [500, {}, ["Actual interactions do not match expected interactions for mock #{name}. See #{log_description} for details."]]
        end
      end

      def example_description env
        params_hash(env)['example_description']
      end
    end
  end
end
