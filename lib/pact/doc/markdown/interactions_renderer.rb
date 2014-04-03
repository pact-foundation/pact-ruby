require 'pact/doc/markdown/interaction_renderer'

module Pact
  module Doc
    module Markdown
      class InteractionsRenderer

        attr_reader :pact

        def initialize pact
          @pact = pact
        end

        def render
          title + summaries.join + full_interactions.join
        end

        def title
          "### A pact between #{pact.consumer.name} and #{pact.provider.name}\n\n"
        end

        def interaction_renderers
          @interaction_renderers ||= pact.interactions.collect{|interaction| InteractionRenderer.new interaction, @pact}.sort
        end

        def summaries
          interaction_renderers.collect(&:render_summary)
        end

        def full_interactions
          interaction_renderers.collect(&:render_full_interaction)
        end

      end
    end
  end
end