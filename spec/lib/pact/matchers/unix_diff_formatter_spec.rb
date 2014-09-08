require 'spec_helper'
require 'pact/matchers/unix_diff_formatter'
require 'pact/matchers/expected_type'
require 'pact/matchers/actual_type'

module Pact
  module Matchers
    describe UnixDiffFormatter do

      describe ".call" do

        let(:key_lines_count) { 4 }
        let(:colour) { false }
        subject { UnixDiffFormatter.call(diff, {colour: colour}) }

        let(:line_count) { subject.split("\n").size }

        context "when colour = false" do
          let(:diff) { {thing: {alligator: Difference.new({name: 'Mary'}, "Joe" )}} }
          it "does not include colour" do
            expect(subject).to_not include("[0m")
          end
        end

        context "when colour = true" do
          let(:colour) { true }
          let(:diff) { {thing: {alligator: Difference.new({name: 'Mary'}, "Joe" )}} }
          it "uses colour" do
            expect(subject).to include("[0m")
          end
        end

        context "with class based matching" do
          let(:diff) { {thing: TypeDifference.new(ExpectedType.new("fred"), ActualType.new(1))}}
          let(:output) { <<-EOF
 {
-  "thing": String
+  "thing": Fixnum
 }
EOF
          }

          it "displays nicely" do
            expect(remove_ansicolor subject).to include output
          end
        end

        context "with an incorrect value in a hash" do
          let(:diff) { {thing: {alligator: Difference.new({name: 'Mary'}, "Joe" )}} }

          it "displays '+' next to the unexpected value, and '-' next to the missing one" do
            expect(subject).to match /alligator/
            expect(subject).to match /\-.*Mary/
            expect(subject).to match /\+.*Joe/
          end

          it "generates the right number of lines, even with ActiveSupport loaded" do
            expect(line_count).to eq 9 + key_lines_count
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

          it "generates the right number of lines, even with ActiveSupport loaded" do
            expect(line_count).to eq 9 + key_lines_count
          end

        end

        context "with a regular expression that was not matched" do
          let(:regexp) { %r{http://.*/thing/1234} }
          let(:diff) { {thing: RegexpDifference.new(regexp, "pear")} }

          it "displays the regular expression" do
            expect(subject).to include(regexp.inspect)
            expect(subject).to include(regexp.inspect)
            expect(subject).to match /\-.*thing/
            expect(subject).to match /\+.*pear/
          end

          it "does not put quotes around the regular expression" do
            expect(subject).to match /\/$/
            expect(subject).to match /: \//
          end

          it "generates the right number of lines, even with ActiveSupport loaded" do
            expect(line_count).to eq 5 + key_lines_count
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

          it "generates the right number of lines, even with ActiveSupport loaded" do
            expect(line_count).to eq 8 + key_lines_count
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

          it "generates the right number of lines, even with ActiveSupport loaded" do
            expect(line_count).to eq 8 + key_lines_count
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

          it "generates the right number of lines, even with ActiveSupport loaded" do
            expect(line_count).to eq 8 + key_lines_count
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

          it "generates the right number of lines, even with ActiveSupport loaded" do
            expect(line_count).to eq 8 + key_lines_count
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

          it "generates the right number of lines, even with ActiveSupport loaded" do
            expect(line_count).to eq 11 + key_lines_count
          end

        end

      end

    end
  end
end