require 'pact/provider/verification_results/verification_result'
module Pact
  module Provider
    module VerificationResults
      class Create

        def self.call pact_json, suite_context
          new(pact_json, suite_context).call
        end

        def initialize pact_json, suite_context
          @pact_json = pact_json
          @suite_context = suite_context
        end

        def call
          VerificationResult.new(!any_failures?, Pact.configuration.provider.application_version)
        end

        private

        def pact_hash
          @pact_hash ||= json_load(pact_json)
        end

        def json_load json
          JSON.load(json, nil, { max_nesting: 50 })
        end

        def count_failures_for_pact_json
          suite_context.reporter.failed_examples.collect{ |e| e.metadata[:pact_json] == pact_json }.uniq.size
        end

        def any_failures?
          count_failures_for_pact_json > 0
        end

        attr_reader :pact_json, :suite_context
      end
    end
  end
end
