module Pact
  module Consumer
    class InteractionPost

      def initialize name, logger, interaction_list
        @name = name
        @logger = logger
        @interaction_list = interaction_list
      end

      def match? env
        env['REQUEST_PATH'] == '/interactions' &&
          env['REQUEST_METHOD'] == 'POST'
      end

      def respond env
        interaction = Interaction.from_hash(JSON.load(env['rack.input'].string))
        @interaction_list.add interaction
        @logger.info "Registered expected interaction #{interaction.request.method_and_path} for #{@name}"
        @logger.ap interaction.as_json
        [200, {}, ['Added interactions']]
      end
    end
  end
end