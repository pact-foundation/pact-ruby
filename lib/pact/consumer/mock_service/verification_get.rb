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

          missing_interactions_summaries = interaction_list.missing_interactions_summaries
          interaction_mismatches_summaries = interaction_list.interaction_mismatches_summaries
          unexpected_requests_summaries = interaction_list.unexpected_requests_summaries
          error_message = "Missing requests:
  #{missing_interactions_summaries.join("\n  ")}
Incorrect requests:
  #{interaction_mismatches_summaries.join("\n  ")}
Unexpected requests:
  #{unexpected_requests_summaries.join("\n  ")}"
logger.warn "Verifying - actual interactions do not match expected interactions for example \"#{example_description(env)}\". \n#{error_message}"
logger.warn error_message
          [500, {}, ["Actual interactions do not match expected interactions for mock #{name}.\n#{error_message}\nSee #{log_description} for details."]]
        end
      end

      def example_description env
        params_hash(env)['example_description']
      end
    end
  end
end
