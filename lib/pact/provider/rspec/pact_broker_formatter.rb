require 'rspec/core/formatters'
require 'pact/provider/verification_results/publish_all'
require 'term/ansicolor'
require 'pact/matchers/extract_diff_messages'

module Pact
  module Provider
    module RSpec
      class PactBrokerFormatter < ::RSpec::Core::Formatters::BaseFormatter
        Pact::RSpec.with_rspec_3 do
          ::RSpec::Core::Formatters.register self, :stop, :close
        end

        attr_reader :output_hash

        def initialize(output)
          super
          @output_hash = {}
        end

        def stop(notification)
          @output_hash[:tests] = notification
                                  .examples
                                  .map { |example| format_example(example) }
        end

        def close(_notification)
          Pact::Provider::VerificationResults::PublishAll.call(Pact.provider_world.pact_sources, output_hash, { verbose: Pact.provider_world.verbose })
        end

      private

        def format_example(example)
          {
            testDescription: example.description,
            testFullDescription: example.full_description,
            status: example.execution_result.status.to_s,
            interactionProviderState: example.metadata[:pact_interaction].provider_state,
            interactionDescription: example.metadata[:pact_interaction].description,
            pact_uri: example.metadata[:pact_uri],
            pact_interaction: example.metadata[:pact_interaction]
          }.tap do |hash|
            if example.exception
              hash[:exception] =  {
                class: example.exception.class.name,
                message: ::Term::ANSIColor.uncolor(example.exception.message)
              }
            end

            if example.metadata[:pact_actual_status]
              hash[:actualStatus] = example.metadata[:pact_actual_status]
            end

            if example.metadata[:pact_actual_headers]
              hash[:actualHeaders] = example.metadata[:pact_actual_headers]
            end

            if example.metadata[:pact_actual_body]
              hash[:actualBody] = example.metadata[:pact_actual_body]
            end

            if example.metadata[:pact_actual_contents]
              hash[:actualContents] = example.metadata[:pact_actual_contents]
            end

            if example.metadata[:pact_diff]
              hash[:differences] = Pact::Matchers::ExtractDiffMessages.call(example.metadata[:pact_diff])
                                    .to_a
                                    .collect{ | description | { description: description } }
            end
          end
        end
      end
    end
  end
end
