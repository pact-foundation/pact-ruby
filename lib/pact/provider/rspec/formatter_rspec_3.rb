require 'pact/provider/print_missing_provider_states'
require 'rspec/core/formatters'
require 'term/ansicolor'
require 'pact/provider/help/prompt_text'

module Pact
  module Provider
    module RSpec
      class Formatter < ::RSpec::Core::Formatters::DocumentationFormatter

        class NilFormatter < ::RSpec::Core::Formatters::BaseFormatter
          Pact::RSpec.with_rspec_3 do
            ::RSpec::Core::Formatters.register self, :start, :example_group_started, :close
          end

          def dump_summary(summary)
          end
        end

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

        def ignore_failures?(summary)
          summary.failed_examples.any?{ |e| e.metadata[:pact_ignore_failures] }
        end

        def failure_title summary
          if ignore_failures?(summary)
            "#{failed_interactions_count(summary)} pending"
          else
            ::RSpec::Core::Formatters::Helpers.pluralize(failed_interactions_count(summary), "failure")
          end
        end

        def totals_line summary
          line = ::RSpec::Core::Formatters::Helpers.pluralize(interactions_count(summary), "interaction")
          line << ", " << failure_title(summary)
          line
        end

        def colorized_totals_line(summary)
          colorizer.wrap(totals_line(summary), color_for_summary(summary))
        end

        def color_for_summary summary
          summary.failure_count > 0 ? ::RSpec.configuration.failure_color : ::RSpec.configuration.success_color
        end

        def print_rerun_commands summary
          if ignore_failures?(summary)
            output.puts("\nPending interactions: (Failures listed here are expected and do not affect your suite's status)\n\n")
          else
            output.puts("\nFailed interactions:\n\n")
          end
          interaction_rerun_commands(summary).each do | message |
            output.puts(message)
          end
        end

        def print_missing_provider_states
          if executing_with_ruby?
            PrintMissingProviderStates.call Pact.provider_world.provider_states.missing_provider_states, output
          end
        end

        def interaction_rerun_commands summary
          summary.failed_examples.collect do |example|
            interaction_rerun_command_for example
          end.uniq.compact
        end

        def interaction_rerun_command_for example
          example_description = example.metadata[:pact_interaction_example_description]

          _id = example.metadata[:pact_interaction]._id
          index = example.metadata[:pact_interaction].index
          provider_state = example.metadata[:pact_interaction].provider_state
          description = example.metadata[:pact_interaction].description
          pactfile_uri = example.metadata[:pactfile_uri]

          if _id && ENV['PACT_INTERACTION_RERUN_COMMAND_FOR_BROKER']
            cmd = String.new(ENV['PACT_INTERACTION_RERUN_COMMAND_FOR_BROKER'])
            cmd.gsub!("<PACT_URI>", example.metadata[:pactfile_uri].to_s)
            cmd.gsub!("<PACT_BROKER_INTERACTION_ID>", "#{_id}")
            colorizer.wrap("#{cmd} ", ::RSpec.configuration.failure_color) + colorizer.wrap("# #{example_description}", ::RSpec.configuration.detail_color)
          elsif ENV['PACT_INTERACTION_RERUN_COMMAND']
            cmd = String.new(ENV['PACT_INTERACTION_RERUN_COMMAND'])
            cmd.gsub!("<PACT_URI>", pactfile_uri.to_s)
            cmd.gsub!("<PACT_DESCRIPTION>", description)
            cmd.gsub!("<PACT_PROVIDER_STATE>", "#{provider_state}")
            cmd.gsub!("<PACT_INTERACTION_INDEX>", "#{index}")
            colorizer.wrap("#{cmd} ", ::RSpec.configuration.failure_color) + colorizer.wrap("# #{example_description}", ::RSpec.configuration.detail_color)
          else
            message = if _id
              "* #{example_description} (to re-run just this interaction, set environment variable PACT_BROKER_INTERACTION_ID=\"#{_id}\")"
            else
              "* #{example_description} (to re-run just this interaction, set environment variables PACT_DESCRIPTION=\"#{description}\" PACT_PROVIDER_STATE=\"#{provider_state}\")"
            end
            colorizer.wrap(message, ::RSpec.configuration.failure_color)
          end
        end

        def print_failure_message
          output.puts(failure_message) if executing_with_ruby?
        end

        def failure_message
          "\n" + Pact::Provider::Help::PromptText.() + "\n"
        end

        def colorizer
          @colorizer ||= ::RSpec::Core::Formatters::ConsoleCodes
        end

        def executing_with_ruby?
          ENV['PACT_EXECUTING_LANGUAGE'] == 'ruby'
        end
      end
    end
  end
end

