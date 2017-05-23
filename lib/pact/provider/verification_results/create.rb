require 'pact/provider/verification_results/verification_result'
module Pact
  module Provider
    module VerificationResults
      class Create

        def self.call pact_json, failed_examples
          new(pact_json, failed_examples).call
        end

        def initialize pact_json, failed_examples
          @pact_json = pact_json
          @failed_examples = failed_examples
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
          failed_examples.collect{ |e| e.metadata[:pact_json] == pact_json }.uniq.size
        end

        def any_failures?
          count_failures_for_pact_json > 0
        end

        attr_reader :pact_json, :failed_examples
      end
    end
  end
end
