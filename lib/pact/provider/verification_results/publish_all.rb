require'pact/provider/verification_results/create'
require'pact/provider/verification_results/publish'

module Pact
  module Provider
    module VerificationResults
      class PublishAll

        def self.call pact_sources, test_results_hash, options = {}
          new(pact_sources, test_results_hash, options).call
        end

        def initialize pact_sources, test_results_hash, options = {}
          @pact_sources = pact_sources
          @test_results_hash = test_results_hash
          @options = options
        end

        def call
          verification_results.collect do | (pact_source, verification_result) |
            published = false
            begin
              published = Publish.call(pact_source, verification_result, { verbose: options[:verbose] })
            ensure
              print_after_verification_notices(pact_source, verification_result, published)
            end
          end
        end

        private

        def verification_results
          pact_sources.collect do | pact_source |
            [pact_source, Create.call(pact_source, test_results_hash)]
          end
        end

        def print_after_verification_notices(pact_source, verification_result, published)
          if pact_source.uri.metadata[:notices]
            pact_source.uri.metadata[:notices].after_verification_notices_text(verification_result.success, published).each do | text |
              Pact.configuration.output_stream.puts "DEBUG: #{text}"
            end
          end
        end

        attr_reader :pact_sources, :test_results_hash, :options
      end
    end
  end
end
