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
          titles_and_summaries.collect do | title, summaries |
            "#{title}:\n\t#{summaries.join("\n  ")}\n\n" if summaries.any?
          end.compact.join

        end

        private

        attr_reader :interaction_list

        def titles_and_summaries
          {
            "Missing requests" => interaction_list.missing_interactions_summaries,
            "Incorrect requests" => interaction_list.interaction_mismatches_summaries,
            "Unexpected requests" => interaction_list.unexpected_requests_summaries,
          }
        end

      end
    end
  end
end
