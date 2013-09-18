module Pact
  module Consumer
    class InteractionList

      attr_reader :interactions
      attr_reader :unexpected_requests

      def initialize
        clear
      end

      # For testing, sigh
      def clear
        @interactions = []
        @matched_interactions = []
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

      def all_matched?
        interaction_diffs.empty?
      end

      def missing_interactions
        @interactions - @matched_interactions
      end

      def interaction_diffs
        {
          :missing_interactions => missing_interactions.collect(&:as_json),
          :unexpected_requests => unexpected_requests.collect(&:as_json)
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