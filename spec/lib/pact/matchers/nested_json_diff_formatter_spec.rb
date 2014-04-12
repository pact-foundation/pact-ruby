require 'spec_helper'
require 'pact/matchers/nested_json_diff_formatter'

module Pact
  module Matchers
    describe NestedJsonDiffFormatter do

      let(:diff) do
        {
          :something => Difference.new({name: 'Fred'}, KeyNotFound.new)
        }
      end

      subject { NestedJsonDiffFormatter.call(diff, options) }

      let(:options) { { colour: colour }}

      describe ".call" do

        let(:colour) { true }

        context "when color_enabled is true" do
          it "returns nicely formatted json" do
            expect(subject.split("\n").size).to eq 8
          end

          it "returns a string displaying the diff in colour" do
            expect(subject).to include NestedJsonDiffFormatter::EXPECTED_COLOURED
            expect(subject).to include NestedJsonDiffFormatter::ACTUAL_COLOURED
          end
        end

        context "when color_enabled is false" do

          let(:colour) { false }

          it "returns nicely formatted json" do
            expect(subject.split("\n").size).to eq 8
          end

          it "returns a string displaying the diff without colour" do
            expect(subject).to_not include NestedJsonDiffFormatter::EXPECTED_COLOURED
            expect(subject).to_not include NestedJsonDiffFormatter::ACTUAL_COLOURED
          end
        end

        context "when no options are specified" do
          subject { NestedJsonDiffFormatter.call(diff) }

          context "when Pact.configuration.color_enabled is true" do
            it "returns a string displaying the diff in colour" do
              expect(Pact.configuration).to receive(:color_enabled).and_return(true)
              expect(subject).to include NestedJsonDiffFormatter::EXPECTED_COLOURED
              expect(subject).to include NestedJsonDiffFormatter::ACTUAL_COLOURED
            end
          end

          context "when Pact.configuration.color_enabled is false" do
            it "returns a string displaying the diff without colour" do
              expect(Pact.configuration).to receive(:color_enabled).and_return(false)
              expect(subject).to_not include NestedJsonDiffFormatter::EXPECTED_COLOURED
              expect(subject).to_not include NestedJsonDiffFormatter::ACTUAL_COLOURED
            end
          end

        end
      end

    end

  end
end