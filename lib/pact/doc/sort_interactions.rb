module Pact
  module Doc
    class SortInteractions

      def self.call interactions
        interactions.sort{|a, b| sortable_id(a) <=> sortable_id(b)}
      end

      private

      def self.sortable_id interaction
        "#{interaction.description.downcase} #{interaction.response.status} #{(interaction.provider_state || '').downcase}"
      end

    end
  end
end