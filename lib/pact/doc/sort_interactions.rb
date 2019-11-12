module Pact
  module Doc
    class SortInteractions

      def self.call interactions
        interactions.sort_by { |interaction| sortable_id(interaction) }
      end

      private

      def self.sortable_id interaction
        "#{interaction.description.downcase} #{interaction.response.status} #{(interaction.provider_state || '').downcase}"
      end
    end
  end
end
