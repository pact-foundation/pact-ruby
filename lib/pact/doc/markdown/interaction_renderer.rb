module Pact
  module Doc
    module Markdown
      def interaction interaction, pact
        @interaction = interaction
        @pact = pact
      end
    end
  end
end