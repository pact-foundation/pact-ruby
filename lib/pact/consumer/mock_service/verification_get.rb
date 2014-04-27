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
          [200, {'Content-Type' => 'text/plain'}, ['Interactions matched']]
        else

          error_message = FailureMessage.new(interaction_list).to_s
          logger.warn "Verifying - actual interactions do not match expected interactions for example \"#{example_description(env)}\". \n#{error_message}"
          logger.warn error_message
          [500, {'Content-Type' => 'text/plain'}, ["Actual interactions do not match expected interactions for mock #{name}.\n\n#{error_message}See #{log_description} for details."]]
        end
      end

      def example_description env
        params_hash(env)['example_description']
      end

      class FailureMessage

        def initialize interaction_list
          @interaction_list = interaction_list
        end

        def to_s
          missing_interactions_summaries = interaction_list.missing_interactions_summaries
          interaction_mismatches_summaries = interaction_list.interaction_mismatches_summaries
          unexpected_requests_summaries = interaction_list.unexpected_requests_summaries
          error_message = ""

          if missing_interactions_summaries.any?
            error_message << "Missing requests:\n\t#{missing_interactions_summaries.join("\n  ")}\n\n"
          end

          if interaction_mismatches_summaries.any?
            error_message << "Incorrect requests:\n\t#{interaction_mismatches_summaries.join("\n  ")}\n\n"
          end

          if unexpected_requests_summaries.any?
            error_message << "Unexpected requests:\n\t#{unexpected_requests_summaries.join("\n  ")}\n\n"
          end
          error_message
        end

        private

        attr_reader :interaction_list

      end
    end
  end
end
