module Pact
  module Consumer
    class InteractionMismatch

      attr_accessor :candidate_interactions, :actual_request

      # Assumes the method and path matches...

      def initialize candidate_interactions, actual_request
        @candidate_interactions = candidate_interactions
        @actual_request = actual_request
        @candiate_diffs = candidate_interactions.collect{ | candidate_interaction| CandidateDiff.new(candidate_interaction, actual_request)}
      end

      def diffs
        candiate_diffs.collect(&:diff_summary)
      end

      def short_summary
        mismatched_attributes = candiate_diffs.collect(&:mismatched_attributes).flatten.uniq.join(", ").reverse.sub(",", "dna ").reverse #OMG what a hack!
        actual_request.method_and_path + " (#{mismatched_attributes} did not match)"
      end

      private

      attr_accessor :candiate_diffs

      class CandidateDiff
        attr_accessor :candidate_interaction, :actual_request
        def initialize candidate_interaction, actual_request
          @candidate_interaction = candidate_interaction
          @actual_request = actual_request
        end

        def mismatched_attributes
          diff.keys
        end

        def diff_summary
          summary = {:description => candidate_interaction.description}
          summary[:provider_state] = candidate_interaction.provider_state if candidate_interaction.provider_state
          summary.merge(diff)
        end

        def diff
          @diff ||= candidate_interaction.request.difference(actual_request)
        end
      end
    end
  end
end