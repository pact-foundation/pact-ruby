module Pact
  module Consumer

    class MissingInteractionsGet
      include RackRequestHelper

      def initialize name, logger, interaction_list
        @name = name
        @logger = logger
        @interaction_list = interaction_list
      end

      def match? env
        env['REQUEST_PATH'].start_with?('/number_of_missing_interactions') &&
            env['REQUEST_METHOD'] == 'GET'
      end

      def respond env
        number_of_missing_interactions = @interaction_list.missing_interactions.size
        @logger.info "Number of missing interactions for mock \"#{@name}\" = #{number_of_missing_interactions}"
        [200, {}, ["#{number_of_missing_interactions}"]]
      end

    end
  end
end