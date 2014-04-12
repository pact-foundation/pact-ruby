require 'pact/doc/markdown/interaction_renderer'

module Pact
  module Doc
    module Markdown
      class InteractionsRenderer

        attr_reader :consumer_contract

        def initialize consumer_contract
          @consumer_contract = consumer_contract
        end

        def self.call consumer_contract
          new(consumer_contract).call
        end

        def call
          title + summaries_title + summaries.join + interactions_title + full_interactions.join
        end

        private

        def title
          "### A pact between #{consumer_contract.consumer.name} and #{consumer_contract.provider.name}\n\n"
        end

        def interaction_renderers
          @interaction_renderers ||= consumer_contract.interactions.collect{|interaction| InteractionRenderer.new interaction, @consumer_contract}.sort
        end

        def summaries_title
          "#### Requests from #{consumer_contract.consumer.name} to #{consumer_contract.provider.name}\n\n"
        end

        def interactions_title
          "#### Interactions\n\n"
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