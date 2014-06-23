require 'spec_helper'
require 'pact/shared/json_differ'

module Pact
  describe JsonDiffer do

    describe ".call" do

      let(:expected) { {'a' => 'b'} }

      subject { JsonDiffer.call(expected, actual) }

      context "when the actual is valid JSON" do

        let(:actual) { {'a' => 'c'} }
        let(:difference) { {'a' => Pact::Matchers::Difference.new('b', 'c')} }

        context "when the actual does not equal the expected" do
          it "parses the JSON and returns a diff" do
            expect(subject).to eq(difference)
          end
        end

        context "when the actual equals the expected" do
          let(:actual) { expected }
          it "parses the JSON and returns an empty diff" do
            expect(subject.any?).to be false
          end
        end

      end

    end

  end
end
