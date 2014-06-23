require 'spec_helper'
require 'pact/shared/text_differ'

module Pact
  describe TextDiffer do

    describe ".call" do

      subject { TextDiffer.call expected, actual }

      let(:expected) { "This is the string you are looking for" }

      context "when the expected and actual are both strings" do

        context "when they equal each other" do
          let(:actual) { "This is the string you are looking for" }

          it "returns an empty diff" do
            expect(subject.any?).to be false
          end
        end

        context "when they don't equal each other" do
          let(:actual) { "This is not the string you are looking for" }

          it "returns the diff" do
            expect(subject).to eq Pact::Matchers::Difference.new(expected, actual)
          end
        end
      end

      context "when the actual is not a String" do
        let(:actual) { {some: 'hash'} }
        let(:difference) { Pact::Matchers::Difference.new(expected, actual)}
        it "returns the diff" do
          expect(subject)
        end
      end

      context "when the expected and actual are both objects" do
        let(:actual) { {some: 'hash', blah: 'blah'} }
        let(:expected) { {some: 'hash'} }
        let(:difference) { Pact::Matchers::Difference.new(expected, actual)}

        it "returns the diff using the JSON matching logic, allowing extra keys. But should it really if the expected Content-Type isn't actually JSON?" do
          expect(subject)
        end

        it "potentially should treat both expected and actual as Strings"
      end

    end
  end
end
