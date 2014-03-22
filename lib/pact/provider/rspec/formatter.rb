require 'pact/provider/print_missing_provider_states'
require 'rspec/core/formatters'

module Pact
  module Provider
    module RSpec
      class Formatter < ::RSpec::Core::Formatters::DocumentationFormatter


        def dump_commands_to_rerun_failed_examples
          return if failed_examples.empty?

          pact_failure_messages.each do | message |
            output.puts(message)
          end

          output.puts failure_message

          PrintMissingProviderStates.call Pact.world.provider_states.missing_provider_states, output
        end

        def pact_failure_messages
          failed_examples.collect do |example|
            provider_state = example.metadata[:pact_interaction].provider_state
            description = example.metadata[:pact_interaction].description
            pactfile_uri = example.metadata[:pactfile_uri]
            example_description = example.metadata[:pact_interaction_example_description]
            failure_color("PACT_DESCRIPTION=\"#{description}\" PACT_PROVIDER_STATE=\"#{provider_state}\" rake pact:verify:at[#{pactfile_uri}]") + " " + detail_color("# #{example_description}")
          end.uniq
        end

        def failure_message
          redify(
            "\nFor assistance debugging failures, please note:\n\n" +
            "The pact files have been stored locally in the following temp directory:\n #{Pact.configuration.tmp_dir}\n\n" +
            "The requests and responses are logged in the following log file:\n #{Pact.configuration.log_path}\n"
          )
        end

        def redify string
          "\e[31m#{string}\e[m"
        end
      end

    end

  end
end


