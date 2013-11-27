module Pact
  module Consumer
    class InteractionList

      attr_reader :interactions
      attr_reader :unexpected_requests
      attr_reader :interaction_mismatches

      def initialize
        clear
      end

      # For testing, sigh
      def clear
        @interactions = []
        @matched_interactions = []
        @interaction_mismatches = []
        @unexpected_requests = []
      end

      def add interactions
        @interactions << interactions
      end

      def register_matched interaction
        @matched_interactions << interaction
      end

      def register_unexpected_request request
        @unexpected_requests << request
      end

      def register_interaction_mismatch interaction_mismatch
        @interaction_mismatches << interaction_mismatch
      end

      def all_matched?
        interaction_diffs.empty?
      end

      def missing_interactions
        @interactions - @matched_interactions - @interaction_mismatches.collect(&:candidate_interactions).flatten
      end

      def missing_interactions_summaries
        missing_interactions.collect(&:request).collect(&:method_and_path)
      end

      def interaction_mismatches_summaries
        interaction_mismatches.collect(&:short_summary)
      end

      def unexpected_requests_summaries
        unexpected_requests.collect(&:method_and_path)
      end

      def interaction_diffs
        {
          :missing_interactions => missing_interactions_summaries,
          :interaction_mismatches => interaction_mismatches_summaries,
          :unexpected_requests => unexpected_requests_summaries
        }.inject({}) do | hash, pair |
          hash[pair.first] = pair.last if pair.last.any?
          hash
        end
      end

      def find_candidate_interactions actual_request
        interactions.select do | interaction |
          interaction.request.matches_route? actual_request
        end
      end

    end
  end
end