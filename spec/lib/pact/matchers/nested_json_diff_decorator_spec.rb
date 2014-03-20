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

        context "when color_enabled is true" do
          it "returns nicely formatted json" do
            expect(subject.to_s.split("\n").size).to eq 8
          end

          it "returns a string displaying the diff in colour" do
            expect(subject.to_s).to include NestedJsonDiffDecorator::EXPECTED_COLOURED
            expect(subject.to_s).to include NestedJsonDiffDecorator::ACTUAL_COLOURED
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
            expect(subject.to_s).to_not include NestedJsonDiffDecorator::EXPECTED_COLOURED
            expect(subject.to_s).to_not include NestedJsonDiffDecorator::ACTUAL_COLOURED
          end
        end
      end

    end

  end
end