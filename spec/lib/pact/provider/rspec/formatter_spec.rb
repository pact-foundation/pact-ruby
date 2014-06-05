require 'spec_helper'
require 'pact/provider/rspec/formatter'
require './spec/support/factories'
require './spec/support/spec_support'

module Pact
  module Provider
    module RSpec
      describe Formatter do

        let(:interaction) { InteractionFactory.create 'provider_state' => 'a state', 'description' => 'a description'}
        let(:pactfile_uri) { 'pact_file_uri' }
        let(:description) { 'an interaction' }
        let(:metadata) { {pact_interaction: interaction, pactfile_uri: pactfile_uri, pact_interaction_example_description: description}}
        let(:example) { double("Example", metadata: metadata) }
        let(:failed_examples) { [example, example] }
        let(:output) { StringIO.new }
        let(:rerun_command) { "rake pact:verify:at[pact_file_uri] PACT_DESCRIPTION=\"a description\" PACT_PROVIDER_STATE=\"a state\" # an interaction" }
        let(:missing_provider_states) { 'missing_provider_states'}

        subject { Formatter.new output }

        let(:output_result) { Pact::SpecSupport.remove_ansicolor output.string }

        before do
          allow(PrintMissingProviderStates).to receive(:call)
          allow(subject).to receive(:failed_examples).and_return(failed_examples)
          allow(Pact.provider_world.provider_states).to receive(:missing_provider_states).and_return(missing_provider_states)
          subject.dump_commands_to_rerun_failed_examples
        end

        describe "#dump_commands_to_rerun_failed_examples" do
          it "prints a list of rerun commands" do
            expect(output_result).to include(rerun_command)
          end

          it "only prints unique commands" do
            expect(output_result.scan(rerun_command).size).to eq 1
          end

          it "prints a message about the logs" do
            expect(output_result).to include("For assistance debugging failures")
          end

          it "prints missing provider states" do
            expect(PrintMissingProviderStates).to receive(:call).with(missing_provider_states, output)
            subject.dump_commands_to_rerun_failed_examples
          end
        end

      end

    end

  end
end


