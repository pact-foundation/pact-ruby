require 'pact/provider/print_missing_provider_states'
require 'rspec/core/formatters/documentation_formatter'
require 'term/ansicolor'
require 'pact/provider/help/prompt_text'

module Pact
  module Provider
    module RSpec
      class Formatter2 < ::RSpec::Core::Formatters::DocumentationFormatter

        C = ::Term::ANSIColor

        def dump_commands_to_rerun_failed_examples
          return if failed_examples.empty?

          print_rerun_commands
          print_failure_message
          print_missing_provider_states

        end

        private

        def print_rerun_commands
          output.puts("\n")
          interaction_rerun_commands.each do | message |
            output.puts(message)
          end
        end

        def print_missing_provider_states
          PrintMissingProviderStates.call Pact.provider_world.provider_states.missing_provider_states, output
        end

        def interaction_rerun_commands
          failed_examples.collect do |example|
            interaction_rerun_command_for example
          end.uniq
        end

        def interaction_rerun_command_for example
          provider_state = example.metadata[:pact_interaction].provider_state
          description = example.metadata[:pact_interaction].description
          pactfile_uri = example.metadata[:pactfile_uri]
          example_description = example.metadata[:pact_interaction_example_description]
          failure_color("bundle exec rake pact:verify:at[#{pactfile_uri}] PACT_DESCRIPTION=\"#{description}\" PACT_PROVIDER_STATE=\"#{provider_state}\"") + " " + detail_color("# #{example_description}")
        end

        def print_failure_message
          output.puts failure_message
        end

        def failure_message
          "\n" + Pact::Provider::Help::PromptText.() + "\n"
        end

      end

    end

  end
end


