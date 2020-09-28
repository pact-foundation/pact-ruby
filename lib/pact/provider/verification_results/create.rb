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
          VerificationResult.new(publishable?, !any_failures?, Pact.configuration.provider.application_version, test_results_hash_for_pact_uri)
        end

        private

        def pact_uri
          @pact_uri ||= pact_source.uri
        end

        def any_failures?
          count_failures_for_pact_uri > 0
        end

        def publishable?
          if defined?(@publishable)
            @publishable
          else
            @publishable = pact_source.consumer_contract.interactions.all? do | interaction |
              examples_for_pact_uri.any?{ |e| example_is_for_interaction?(e, interaction) }
            end && examples_for_pact_uri.count > 0
          end
        end

        def example_is_for_interaction?(example, interaction)
          # Use the Pact Broker id if supported
          if interaction._id
            example[:pact_interaction]._id == interaction._id
          else
            # fall back to object equality (based on the field values of the interaction)
            example[:pact_interaction] == interaction
          end
        end

        def examples_for_pact_uri
          @examples_for_pact_uri ||= test_results_hash[:tests].select{ |e| e[:pact_uri] == pact_uri }
        end

        def count_failures_for_pact_uri
          examples_for_pact_uri.count{ |e| e[:status] != 'passed' }
        end

        def test_results_hash_for_pact_uri
          {
            tests: examples_for_pact_uri.collect{ |e| clean_example(e) },
            summary: {
              testCount: examples_for_pact_uri.size,
              failureCount: count_failures_for_pact_uri
            },
            metadata: {
              warning: "These test results use a beta format. Do not rely on it, as it will definitely change.",
              pactVerificationResultsSpecification: {
                version: "1.0.0-beta.1"
              }
            }
          }
        end

        def clean_example(example)
          example.reject{ |k, v| k == :pact_uri || k == :pact_interaction }
        end

        attr_reader :pact_source, :test_results_hash
      end
    end
  end
end
