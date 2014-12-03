require 'pact/provider/print_missing_provider_states'
require 'rspec/core/formatters'
require 'term/ansicolor'

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
          summary.examples.collect{ |e|e.metadata[:pact_interaction_example_description]}.uniq.size
        end

        def failed_interactions_count(summary)
          summary.failed_examples.collect{ |e|e.metadata[:pact_interaction_example_description]}.uniq.size
        end

        def totals_line summary
          line = ::RSpec::Core::Formatters::Helpers.pluralize(interactions_count(summary), "interaction")
          line << ", " << ::RSpec::Core::Formatters::Helpers.pluralize(failed_interactions_count(summary), "failure")
          line
        end

        def colorized_totals_line(summary)
          if summary.failure_count > 0
            colorizer.wrap(totals_line(summary), ::RSpec.configuration.failure_color)
          else
            colorizer.wrap(totals_line(summary), ::RSpec.configuration.success_color)
          end
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
          colorizer.wrap("rake pact:verify:at[#{pactfile_uri}] PACT_DESCRIPTION=\"#{description}\" PACT_PROVIDER_STATE=\"#{provider_state}\" ", ::RSpec.configuration.failure_color) +
            colorizer.wrap("# #{example_description}", ::RSpec.configuration.detail_color)
        end

        def print_failure_message
          output.puts failure_message
        end

        def failure_message
          "\n" +  C.underline(C.yellow("For assistance debugging failures, please note:")) + "\n\n" +
          "The pact files have been stored locally in the following temp directory:\n #{Pact.configuration.tmp_dir}\n\n" +
          "The requests and responses are logged in the following log file:\n #{Pact.configuration.log_path}\n\n" +
          "Add BACKTRACE=true to the `rake pact:verify` command to see the full backtrace\n\n"
        end

        def colorizer
          @colorizer ||= ::RSpec::Core::Formatters::ConsoleCodes
        end

      end

    end

  end
end


