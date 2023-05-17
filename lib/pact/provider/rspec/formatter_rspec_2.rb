require 'pact/provider/print_missing_provider_states'
require 'rspec/core/formatters/documentation_formatter'
require 'term/ansicolor'
require 'pact/provider/help/prompt_text'

module Pact
  module Provider
    module RSpec
      class Formatter2 < ::RSpec::Core::Formatters::DocumentationFormatter

        class NilFormatter < ::RSpec::Core::Formatters::DocumentationFormatter
          def dump_commands_to_rerun_failed_examples
          end
        end

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
          if executing_with_ruby?
            PrintMissingProviderStates.call Pact.provider_world.provider_states.missing_provider_states, output
          end
        end

        def interaction_rerun_commands
          failed_examples.collect do |example|
            interaction_rerun_command_for example
          end.uniq
        end

        def interaction_rerun_command_for example
          example_description = example.metadata[:pact_interaction_example_description]
          if ENV['PACT_INTERACTION_RERUN_COMMAND']
            cmd = String.new(ENV['PACT_INTERACTION_RERUN_COMMAND'])
            provider_state = example.metadata[:pact_interaction].provider_state
            description = example.metadata[:pact_interaction].description
            pactfile_uri = example.metadata[:pactfile_uri]
            cmd.gsub!("<PACT_URI>", pactfile_uri.to_s)
            cmd.gsub!("<PACT_DESCRIPTION>", description)
            cmd.gsub!("<PACT_PROVIDER_STATE>", "#{provider_state}")
            failure_color(cmd) + " " + detail_color("# #{example_description}")
          else
            failure_color("* #{example_description}")
          end
        end

        def print_failure_message
          output.puts(failure_message) if executing_with_ruby?
        end

        def failure_message
          "\n" + Pact::Provider::Help::PromptText.() + "\n"
        end

        def executing_with_ruby?
          ENV['PACT_EXECUTING_LANGUAGE'] == 'ruby'
        end
      end
    end
  end
end
