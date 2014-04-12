require 'pact/matchers/nested_json_diff_formatter'

module Pact
  module Consumer

    # Presents the differences between an actual request, and a list of
    # expected interactions where the methods and paths match the actual request.
    # This is used to display a helpful message to the user when a request
    # comes in that doesn't match any of the expected interactions.
    class InteractionMismatch

      attr_accessor :candidate_interactions, :actual_request

      # Assumes the method and path matches...

      def initialize candidate_interactions, actual_request
        @candidate_interactions = candidate_interactions
        @actual_request = actual_request
        @candiate_diffs = candidate_interactions.collect{ | candidate_interaction| CandidateDiff.new(candidate_interaction, actual_request)}
      end

      def to_hash
        candiate_diffs.collect(&:to_hash)
      end

      def to_s
        candiate_diffs.collect(&:to_s).join("\n")
      end

      def short_summary
        mismatched_attributes = candiate_diffs.collect(&:mismatched_attributes).flatten.uniq.join(", ").reverse.sub(",", "dna ").reverse #OMG what a hack!
        actual_request.method_and_path + " (request #{mismatched_attributes} did not match)"
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

        def to_hash
          summary = {:description => candidate_interaction.description}
          summary[:provider_state] = candidate_interaction.provider_state if candidate_interaction.provider_state
          summary.merge(diff)
        end

        def to_s
          [
            "Diff with interaction: #{candidate_interaction.description_with_provider_state_quoted}",
            Pact::Matchers::NestedJsonDiffFormatter.call(diff, false)
          ].join("\n")
        end

        def diff
          @diff ||= candidate_interaction.request.difference(actual_request)
        end
      end
    end
  end
end