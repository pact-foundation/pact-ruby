require 'pact/provider/rspec/calculate_exit_code'

module Pact
  module Provider
    module RSpec
      module CalculateExitCode
        describe ".call" do
          let(:pact_source_1) { double('pact_source_1', pending?: pending_1) }
          let(:pending_1) { nil }
          let(:pact_source_2) { double('pact_source_2', pending?: pending_2) }
          let(:pending_2) { nil }
          let(:pact_source_3) { double('pact_source_3', pending?: pending_3) }
          let(:pending_3) { nil }
          let(:pact_sources) { [pact_source_1, pact_source_2, pact_source_3]}

          let(:failed_examples) { [ example_1, example_2, example_3 ] }
          let(:example_1) { double('example_1', metadata: { pact_source: pact_source_1 }) }
          let(:example_2) { double('example_2', metadata: { pact_source: pact_source_1 }) }
          let(:example_3) { double('example_3', metadata: { pact_source: pact_source_2 }) }

          subject { CalculateExitCode.call(pact_sources, failed_examples ) }

          context "when all pacts are pending" do
            let(:pending_1) { true }
            let(:pending_2) { true }
            let(:pending_3) { true }

            it "returns 0" do
              expect(subject).to eq 0
            end
          end

          context "when a non pending pact has no failures" do
            let(:pending_1) { true }
            let(:pending_2) { true }
            let(:pending_3) { false }

            it "returns 0" do
              expect(subject).to eq 0
            end
          end

          context "when a non pending pact no failures" do
            let(:pending_1) { true }
            let(:pending_2) { false }
            let(:pending_3) { false }

            it "returns 1" do
              expect(subject).to eq 1
            end
          end
        end
      end
    end
  end
end
