require 'pact/provider/print_missing_provider_states'
require 'rspec/core/formatters'
require 'term/ansicolor'
require 'pact/provider/help/prompt_text'

module Pact
  module Provider
    module RSpec
      class Formatter < ::RSpec::Core::Formatters::DocumentationFormatter

        Pact::RSpec.with_rspec_3 do
          ::RSpec::Core::Formatters.register self, :example_group_started, :example_group_finished,
                                    :example_passed, :example_pending, :example_failed
        end

        C = ::Term::ANSIColor

        def dump_summary(summary)
          output.puts "\n" + colorized_totals_line(summary)
          return if summary.failure_count == 0
          print_rerun_commands summary
          print_failure_message
          print_missing_provider_states
        end

        private

        def interactions_count(summary)
          summary.examples.collect{ |e| e.metadata[:pact_interaction_example_description] }.uniq.size
        end

        def failed_interactions_count(summary)
          summary.failed_examples.collect{ |e| e.metadata[:pact_interaction_example_description] }.uniq.size
        end

        def totals_line summary
          line = ::RSpec::Core::Formatters::Helpers.pluralize(interactions_count(summary), "interaction")
          line << ", " << ::RSpec::Core::Formatters::Helpers.pluralize(failed_interactions_count(summary), "failure")
          line
        end

        def colorized_totals_line(summary)
          colorizer.wrap(totals_line(summary), color_for_summary(summary))
        end

        def color_for_summary summary
          summary.failure_count > 0 ? ::RSpec.configuration.failure_color : ::RSpec.configuration.success_color
        end

        def print_rerun_commands summary
          output.puts("\nFailed interactions:\n\n")
          interaction_rerun_commands(summary).each do | message |
            output.puts(message)
          end
        end

        def print_missing_provider_states
          PrintMissingProviderStates.call Pact.provider_world.provider_states.missing_provider_states, output
        end

        def interaction_rerun_commands summary
          summary.failed_examples.collect do |example|
            interaction_rerun_command_for example
          end.uniq
        end

        def interaction_rerun_command_for example
          provider_state = example.metadata[:pact_interaction].provider_state
          description = example.metadata[:pact_interaction].description
          pactfile_uri = example.metadata[:pactfile_uri]
          example_description = example.metadata[:pact_interaction_example_description]
          colorizer.wrap("bundle exec rake pact:verify:at[#{pactfile_uri}] PACT_DESCRIPTION=\"#{description}\" PACT_PROVIDER_STATE=\"#{provider_state}\" ", ::RSpec.configuration.failure_color) +
            colorizer.wrap("# #{example_description}", ::RSpec.configuration.detail_color)
        end

        def print_failure_message
          output.puts failure_message
        end

        def failure_message
          "\n" + Pact::Provider::Help::PromptText.() + "\n"
        end

        def colorizer
          @colorizer ||= ::RSpec::Core::Formatters::ConsoleCodes
        end

      end

    end

  end
end


