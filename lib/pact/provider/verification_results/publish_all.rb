require'pact/provider/verification_results/create'
require'pact/provider/verification_results/publish'

module Pact
  module Provider
    module VerificationResults
      class PublishAll

        def self.call pact_sources, rspec_summary
          new(pact_sources, rspec_summary).call
        end

        def initialize pact_sources, rspec_summary
          @pact_sources = pact_sources
          @rspec_summary = rspec_summary
        end

        def call
          verification_results.collect do | pair |
            Publish.call(pair.first, pair.last)
          end
        end

        private

        def verification_results
          pact_sources.collect do | pact_source |
            [pact_source, Create.call(pact_source.pact_json, rspec_summary)]
          end
        end

        attr_reader :pact_sources, :rspec_summary
      end
    end
  end
end
