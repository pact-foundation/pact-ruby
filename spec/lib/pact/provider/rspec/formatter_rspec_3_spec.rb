require 'spec_helper'
require 'pact/provider/rspec/formatter_rspec_3'
require './spec/support/factories'
require './spec/support/spec_support'
require 'pact/tasks/task_helper'

Pact::RSpec.with_rspec_3 do
  module Pact
    module Provider
      module RSpec
        describe Formatter do

          let(:interaction) { InteractionFactory.create 'provider_state' => 'a state', 'description' => 'a description'}
          let(:pactfile_uri) { 'pact_file_uri' }
          let(:description) { 'an interaction' }
          let(:pact_json) { {some: 'pact json'}.to_json }
          let(:metadata) do
            {
              pact_interaction: interaction,
              pactfile_uri: pactfile_uri,
              pact_interaction_example_description: description,
              pact_json: pact_json
            }
          end
          let(:metadata_2) { metadata.merge(pact_interaction_example_description: 'another interaction')}
          let(:example) { double("Example", metadata: metadata) }
          let(:example_2) { double("Example", metadata: metadata_2) }
          let(:failed_examples) { [example, example] }
          let(:examples) { [example, example, example_2]}
          let(:output) { StringIO.new }
          let(:rerun_command) { "rake pact:verify:at[pact_file_uri] PACT_DESCRIPTION=\"a description\" PACT_PROVIDER_STATE=\"a state\" # an interaction" }
          let(:missing_provider_states) { 'missing_provider_states'}
          let(:summary) { double("summary", failure_count: 1, failed_examples: failed_examples, examples: examples)}
          let(:pact_executing_language) { 'ruby' }
          let(:pact_interaction_rerun_command) { Pact::TaskHelper::PACT_INTERACTION_RERUN_COMMAND }

          subject { Formatter.new output }

          let(:output_result) { Pact::SpecSupport.remove_ansicolor output.string }

          before do
            allow(ENV).to receive(:[]).with('PACT_INTERACTION_RERUN_COMMAND').and_return(pact_interaction_rerun_command)
            allow(ENV).to receive(:[]).with('PACT_EXECUTING_LANGUAGE').and_return(pact_executing_language)
            allow(PrintMissingProviderStates).to receive(:call)
            allow(Pact::Provider::Help::PromptText).to receive(:call).and_return("some help")
            allow(subject).to receive(:failed_examples).and_return(failed_examples)
            allow(Pact.provider_world.provider_states).to receive(:missing_provider_states).and_return(missing_provider_states)
            subject.dump_summary summary
          end

          describe "#dump_summary" do
            it "prints the number of interactions" do
              expect(output_result).to include("2 interactions")
            end

            it "prints the number of failures" do
              expect(output_result).to include("1 failure")
            end

            context "when PACT_INTERACTION_RERUN_COMMAND is set" do
              it "prints a list of rerun commands" do
                expect(output_result).to include(rerun_command)
              end

              it "only prints unique commands" do
                expect(output_result.scan(rerun_command).size).to eq 1
              end
            end

            context "when PACT_INTERACTION_RERUN_COMMAND is not set" do
              let(:pact_interaction_rerun_command) { nil }

              it "prints a list of failed interactions" do
                expect(output_result).to include("* #{description}\n")
              end

              it "only prints unique commands" do
                expect(output_result.scan("* #{description}\n").size).to eq 1
              end
            end

            context "when PACT_EXECUTING_LANGUAGE is ruby" do
              it "explains how get help debugging" do
                expect(output_result).to include("some help")
              end

              it "prints missing provider states" do
                expect(PrintMissingProviderStates).to receive(:call).with(missing_provider_states, output)
                subject.dump_summary summary
              end
            end

            context "when PACT_EXECUTING_LANGUAGE is not ruby" do
              let(:pact_executing_language) { 'foo' }

              it "does not explain how get help debugging as the rake task is not exposed for other languages" do
                expect(output_result).to_not include("some help")
              end

              it "does not print missing provider states as these are set up dynamically" do
                expect(PrintMissingProviderStates).to_not receive(:call)
                subject.dump_commands_to_rerun_failed_examples
              end
            end
          end
        end
      end
    end
  end
end
