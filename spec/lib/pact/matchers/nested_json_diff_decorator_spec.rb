require 'spec_helper'
require 'pact/matchers/nested_json_diff_decorator'

module Pact
  module Matchers
    describe NestedJsonDiffDecorator do

      let(:diff) do
        {
          :something => Difference.new({name: 'Fred'}, KeyNotFound.new)
        }
      end

      subject { NestedJsonDiffDecorator.new(diff) }

      describe "#to_s" do

        let(:expected_green) { "expected".green }
        let(:expected_green) { "actual".red }

        context "when color_enabled is true" do
          it "returns nicely formatted json" do
            expect(subject.to_s.split("\n").size).to eq 8
          end

          it "returns a string displaying the diff in colour" do
            expect(subject.to_s).to include NestedJsonDiffDecorator::EXPECTED_GREEN
            expect(subject.to_s).to include NestedJsonDiffDecorator::ACTUAL_RED
          end
        end

        context "when color_enabled is false" do
          before do
            Pact.configuration.stub(:color_enabled).and_return(false)
          end

          it "returns nicely formatted json" do
            expect(subject.to_s.split("\n").size).to eq 8
          end

          it "returns a string displaying the diff without colour" do
            expect(subject.to_s).to_not include "expected".green
            expect(subject.to_s).to_not include "actual".red
          end
        end
      end

    end

  end
end