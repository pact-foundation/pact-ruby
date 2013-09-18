module Pact
  module Consumer
    class VerificationGet

      include RackRequestHelper

      def initialize name, logger, log_description, interaction_list
        @name = name
        @logger = logger
        @log_description = log_description
        @interaction_list = interaction_list
      end

      def match? env
        env['REQUEST_PATH'].start_with?('/verify') &&
          env['REQUEST_METHOD'] == 'GET'
      end

      def respond env
        if @interaction_list.all_matched?
          @logger.info "Verifying - interactions matched for example \"#{example_description(env)}\""
          [200, {}, ['Interactions matched']]
        else
          @logger.warn "Verifying - actual interactions do not match expected interactions for example \"#{example_description(env)}\". Interaction diffs:"
          @logger.ap @interaction_list.interaction_diffs, :warn
          [500, {}, ["Actual interactions do not match expected interactions for mock #{@name}. See #{@log_description} for details."]]
        end
      end

      def example_description env
        params_hash(env)['example_description']
      end
    end
  end
end
