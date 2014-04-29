require 'pact/consumer/mock_service/mock_service_administration_endpoint'

module Pact
  module Consumer
    class InteractionPost < MockServiceAdministrationEndpoint

      attr_accessor :interaction_list

      def initialize name, logger, interaction_list
        super name, logger
        @interaction_list = interaction_list
      end

      def request_path
        '/interactions'
      end

      def request_method
        'POST'
      end

      def respond env
        interaction = Interaction.from_hash(JSON.load(env['rack.input'].string))
        interaction_list.add interaction
        logger.info "Registered expected interaction #{interaction.request.method_and_path}"
        logger.debug JSON.pretty_generate JSON.parse(interaction.to_json)
        [200, {}, ['Added interaction']]
      end
    end
  end
end
