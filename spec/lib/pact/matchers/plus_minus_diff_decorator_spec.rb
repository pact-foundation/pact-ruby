require 'spec_helper'
require 'pact/matchers/plus_minus_diff_decorator'

module Pact
  module Matchers
    describe PlusMinusDiffDecorator do

      describe "#to_s" do

        subject { PlusMinusDiffDecorator.new(diff) }

        context "with an incorrect value" do
          let(:diff) { {thing: {alligator: Difference.new({name: 'Mary'}, "Joe" )}} }

          it "does something" do
            puts subject.to_s
          end
        end

        context "with a missing index" do
          let(:diff) { [NoDiffIndicator.new, Difference.new({name: 'Mary'}, "Joe")] }

          it "does something" do
            puts subject.to_s
          end
        end

        context "with a missing key" do
          let(:diff) { {thing: {alligator: Difference.new({name: 'Mary'}, KeyNotFound.new )}} }

          it "does something" do
            puts subject.to_s
          end
        end

      end

    end
  end
end