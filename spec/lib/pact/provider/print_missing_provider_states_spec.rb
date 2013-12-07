require 'spec_helper'
require 'pact/provider/print_missing_provider_states'

module Pact
  module Provider
    describe PrintMissingProviderStates do

      describe "text" do
        let(:missing_provider_states) { {'Consumer 1' => ['state1','state2'], 'Consumer 2' => ['state3']} }
        let(:expected_output) { File.read("./spec/support/missing_provider_states_output.txt")}
        subject { PrintMissingProviderStates.text missing_provider_states }
        it "returns the text" do
          expect(subject).to include expected_output
        end
      end

    end
  end
end