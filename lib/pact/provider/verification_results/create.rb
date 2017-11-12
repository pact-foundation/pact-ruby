require 'pact/provider/verification_results/verification_result'
module Pact
  module Provider
    module VerificationResults
      class Create

        def self.call pact_source, test_results_hash
          new(pact_source, test_results_hash).call
        end

        def initialize pact_source, test_results_hash
          @pact_source = pact_source
          @test_results_hash = test_results_hash
        end

        def call
          VerificationResult.new(!any_failures?, Pact.configuration.provider.application_version, test_results_hash_for_pact_uri)
        end

        private

        def pact_uri
          @pact_uri ||= pact_source.uri
        end

        def any_failures?
          count_failures_for_pact_uri > 0
        end

        def examples_for_pact_uri
          @examples_for_pact_uri ||= test_results_hash[:examples]
                                      .select{ |e| e[:pact_uri] == pact_uri }
                                      .collect{ |e| clean_example(e) }
        end

        def count_failures_for_pact_uri
          examples_for_pact_uri.count{ |e| e[:status] != 'passed' }
        end

        def test_results_hash_for_pact_uri
          {
            examples: examples_for_pact_uri,
            summary: {
              exampleCount: examples_for_pact_uri.size,
              failureCount: count_failures_for_pact_uri
            }
          }
        end

        def clean_example(example)
          example.reject{ |k, v| k == :pact_uri }
        end

        attr_reader :pact_source, :test_results_hash
      end
    end
  end
end
