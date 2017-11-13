require 'rspec/core/formatters'
require 'pact/provider/verification_results/publish_all'
require 'term/ansicolor'

module Pact
  module Provider
    module RSpec
      class PactBrokerFormatter < ::RSpec::Core::Formatters::BaseFormatter
        Pact::RSpec.with_rspec_3 do
          ::RSpec::Core::Formatters.register self, :message, :dump_summary, :stop, :seed, :close
        end

        attr_reader :output_hash

        def initialize(output)
          super
          @output_hash = {
            :version => ::RSpec::Core::Version::STRING
          }
        end

        def message(notification)
          (@output_hash[:messages] ||= []) << notification.message
        end

        def dump_summary(summary)
        end

        def stop(notification)
          @output_hash[:examples] = notification.examples.map do |example|
            format_example(example).tap do |hash|
              e = example.exception
              if e
                hash[:exception] =  {
                  class: e.class.name,
                  message: ::Term::ANSIColor.uncolor(e.message)
                }
              end
            end
          end
        end

        def seed(notification)
          return unless notification.seed_used?
          @output_hash[:seed] = notification.seed
        end

        def close(_notification)
          Pact::Provider::VerificationResults::PublishAll.call(Pact.provider_world.pact_sources, output_hash)
        end

      private

        def format_example(example)
          {
            exampleDescription: example.description,
            exampleFullDescription: example.full_description,
            status: example.execution_result.status.to_s,
            interactionProviderState: example.metadata[:pact_interaction].provider_state,
            interactionDescription: example.metadata[:pact_interaction].description,
            pact_uri: example.metadata[:pact_uri],
            pact_interaction: example.metadata[:pact_interaction]
          }
        end
      end
    end
  end
end
