require 'spec_helper'
require 'pact/matchers/plus_minus_diff_decorator'

module Pact
  module Matchers
    describe PlusMinusDiffDecorator do

      describe "#to_s" do

        subject { PlusMinusDiffDecorator.new(diff).to_s }

        context "with an incorrect value in a hash" do
          let(:diff) { {thing: {alligator: Difference.new({name: 'Mary'}, "Joe" )}} }

          it "does something" do
            expect(subject).to match /alligator/
            expect(subject).to match /\-.*Mary/
            expect(subject).to match /\+.*Joe/
          end
        end

        context "with an incorrect value in an array" do
          let(:diff) { [NoDiffIndicator.new, Difference.new({name: 'Mary'}, "Joe"), NoDiffIndicator.new] }

          it "displays '+' next to the incorrect values and '-' next to the missing ones" do
            expect(subject).to match /no difference here!/
            expect(subject).to match /\-.*{/
            expect(subject).to match /\-.*}/
            expect(subject).to match /\-.*Mary/
            expect(subject).to match /\+.*Joe/
            expect(subject).to match /no.*Mary.*Joe.*no/m
          end

          it "doesn't display the no difference indicator as a change" do
            expect(subject).to match(/^\s+no difference here!,$/)
          end
        end

        context "with a missing key" do

          let(:diff) { {thing: {alligator: Difference.new({name: 'Mary'}, KeyNotFound.new )}} }

          it "it displays '-' next to the missing key and its value" do
            expect(subject).to match /\-.*{/
            expect(subject).to match /\-.*}/
            expect(subject).to match /\-.*alligator/
            expect(subject).to match /\-.*name/
            expect(subject).to match /\-.*Mary/
          end

          it "does not display the missing key in the actual output" do
            expect(subject).to_not match /\+.*alligator/
          end

        end

        context "with an unexpected key" do
          let(:diff) { {thing: {alligator: Difference.new(UnexpectedKey.new, {name: 'Mary'} )}} }

          it "displays '+' next to the unexpected key and its value" do
            expect(subject).to match /\+.*name/
            expect(subject).to match /\+.*Mary/
            expect(subject).to match /\+.*alligator/
            expect(subject).to match /\+.*}/
            expect(subject).to match /\+.*{/
          end

          it "does not display the unexpected key in the expected output" do
            expect(subject).to_not match /\-.*alligator/
          end
        end

        context "with a missing index" do
          let(:diff) { [NoDiffIndicator.new, Difference.new({name: 'Mary'}, IndexNotFound.new)] }

          it "displays '-' next to the missing items" do
            expect(subject).to match /\-.*Mary/
            expect(subject).to match /\-.*{/
            expect(subject).to match /\-.*}/
          end

          it "does not display IndexNotFound" do
            expect(subject).to_not match /#{IndexNotFound.new.to_s}/
          end
        end

        context "with an unexpected index" do
          let(:diff) { [NoDiffIndicator.new, Difference.new(UnexpectedIndex.new, {name: 'Mary'})] }

          it "displays '+' next to the unexpected item" do
            expect(subject).to match /\+.*{/
            expect(subject).to match /\+.*}/
            expect(subject).to match /\+.*name/
            expect(subject).to match /\+.*Mary/
          end

          xit "doesn't mark the 'no difference' as a change" do
            expect(subject).to match /#{NoDiffIndicator.new.to_s},/
            expect(subject).to_not match /\-.*#{NoDiffIndicator.new.to_s}/
            expect(subject).to_not match /\+.*#{NoDiffIndicator.new.to_s}/
          end

          it "does not display the UnexpectedIndex" do
            expect(subject).to_not match UnexpectedIndex.new.to_s
          end
        end

        context "with 2 unexpected indexes" do
          let(:diff) { [NoDiffIndicator.new, Difference.new(UnexpectedIndex.new, {name: 'Mary'}), Difference.new(UnexpectedIndex.new, {name: 'Joe'})] }

          it "displays '+' next to the unexpected item" do
            expect(subject).to match /\+.*Mary/
            expect(subject).to match /\+.*Joe/
          end

          it "does not display the UnexpectedIndex" do
            expect(subject).to_not match UnexpectedIndex.new.to_s
          end
        end

      end

    end
  end
end