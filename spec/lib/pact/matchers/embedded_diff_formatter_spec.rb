require 'spec_helper'
require 'pact/matchers/embedded_diff_formatter'
require 'pact/matchers/type_difference'
require 'pact/matchers/expected_type'
require 'pact/matchers/actual_type'

module Pact
  module Matchers
    describe EmbeddedDiffFormatter do

      let(:diff) do
        {
          :something => TypeDifference.new(ExpectedType.new("Fred"), ActualType.new(1))
        }
      end

      subject { EmbeddedDiffFormatter.call(diff, options) }

      let(:options) { { colour: colour }}
      let(:expected_coloured) { '"' + ::Term::ANSIColor.red("expected_type") + '":'}
      let(:actual_coloured) { '"' + ::Term::ANSIColor.green("actual_type") + '":'}

      describe ".call" do

        let(:colour) { false }

        context "when color_enabled is true" do

          let(:colour) { true }

          it "returns nicely formatted json" do
            expect(subject.split("\n").size).to eq 6
          end

          it "returns a string displaying the diff in colour" do
            expect(subject).to include expected_coloured
            expect(subject).to include actual_coloured
          end
        end

        context "when color_enabled is false" do

          let(:colour) { false }

          it "returns nicely formatted json" do
            expect(subject.split("\n").size).to eq 6
          end

          it "returns a string displaying the diff without colour" do
            expect(subject).to_not include expected_coloured
            expect(subject).to_not include actual_coloured
          end
        end

        context "with a Pact::Term" do
          let(:diff) { {thing: Difference.new(Pact::Term.new(generate: "Joe", matcher: /Jo/), "Mary")} }

          xit "displays the matcher from the Pact::Term" do
            expect(subject).to_not include("Pact::Term")
            expect(subject).to include("/Jo/")
          end

        end

        context "when no options are specified" do
          subject { EmbeddedDiffFormatter.call(diff) }

          context "when Pact.configuration.color_enabled is true" do
            it "returns a string displaying the diff in colour" do
              expect(Pact.configuration).to receive(:color_enabled).and_return(true)
              expect(subject).to include expected_coloured
              expect(subject).to include actual_coloured
            end
          end

          context "when Pact.configuration.color_enabled is false" do
            it "returns a string displaying the diff without colour" do
              expect(Pact.configuration).to receive(:color_enabled).and_return(false)
              expect(subject).to_not include expected_coloured
              expect(subject).to_not include actual_coloured
            end
          end

        end
      end

    end

  end
end