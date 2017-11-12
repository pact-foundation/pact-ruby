require'pact/provider/verification_results/create'
require'pact/provider/verification_results/publish'

module Pact
  module Provider
    module VerificationResults
      class PublishAll

        def self.call pact_sources, test_results_hash
          new(pact_sources, test_results_hash).call
        end

        def initialize pact_sources, test_results_hash
          @pact_sources = pact_sources
          @test_results_hash = test_results_hash
        end

        # TODO do not publish unless all interactions have been run
        def call
          verification_results.collect do | pair |
            Publish.call(pair.first, pair.last)
          end
        end

        private

        def verification_results
          pact_sources.collect do | pact_source |
            [pact_source, Create.call(pact_source, test_results_hash)]
          end
        end

        attr_reader :pact_sources, :test_results_hash
      end
    end
  end
end
