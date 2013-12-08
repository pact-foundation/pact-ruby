require 'spec_helper'
require 'pact/matchers/diff_decorator'
require 'pact/matchers/matchers'

module Pact
  module Matchers
    describe DiffDecorator do

      describe "to_s" do
        subject { DiffDecorator.new(diff) }

        context "when there is a mismatched value" do
          let(:diff) { {root: {"blah" => { 1 => Difference.new("alphabet", "woozle")}}} }
          let(:expected_output) { ""}

          it "includes the expected value" do
            expect(subject.to_s).to include('Expected: "alphabet"')
          end
          it "includes the actual value" do
            expect(subject.to_s).to include('Actual: "woozle"')
          end

          it "includes the path" do
            expect(subject.to_s).to include('At [:root]["blah"][1]')
          end
        end

        context "when there is a missing key" do
          let(:expected_hash) { {"abc" => {"def" => [1,2]}}}
          let(:diff) { {root: {"blah" => { 1 => Difference.new(expected_hash, Pact::KeyNotFound.new )}}} }
          let(:expected_output) { ""}

          it "includes the expected value" do
            expect(subject.to_s).to include("Missing: {")
          end

          it "includes the path" do
            expect(subject.to_s).to include('At [:root]["blah"][1]')
          end
        end

        context "when there is a missing index" do
          let(:diff) { [NoDiffIndicator.new, Difference.new(1, IndexNotFound.new )]}
          it "includes the expected value" do
            expect(subject.to_s).to include("Missing: 1")
          end

          it "includes the path" do
            expect(subject.to_s).to include('At [1]')
          end
        end

        context "when there is an unexpected index" do
          let(:diff) { [NoDiffIndicator.new, Difference.new(UnexpectedIndex.new, 2), Difference.new(UnexpectedIndex.new, "b")]}
          it "includes the unexpected value" do
            expect(subject.to_s).to include("Array contained unexpected item: ")
          end

          it "includes the path" do
            expect(subject.to_s).to include('At [1]')
            expect(subject.to_s).to include('At [2]')
          end
        end

        context "when there is an unexpected key" do
          let(:diff) { {"blah" => Difference.new(UnexpectedKey.new, "b")}}
          it "includes the unexpected key" do
            expect(subject.to_s).to include("Hash contained unexpected key with value:")
          end

          it "includes the path" do
            expect(subject.to_s).to include('At ["blah"]')
          end
        end

      end

    end
  end
end