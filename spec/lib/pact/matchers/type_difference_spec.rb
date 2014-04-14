require 'spec_helper'
require 'pact/matchers/type_difference'

module Pact
  module Matchers
    describe TypeDifference do

      describe "#as_json" do

        let(:expected) { ExpectedType.new("Fred") }
        let(:actual) { ActualType.new(1) }
        subject { TypeDifference.new expected, actual }

        context "when the actual is a KeyNotFound" do
          let(:actual) { KeyNotFound.new }
          let(:expected_hash) { {:EXPECTED_TYPE => "String", :ACTUAL => actual.to_s } }

          it "use the key ACTUAL" do
            expect(subject.as_json).to eq(expected_hash)
          end
        end

        context "when the actual is an ActualType" do
          let(:expected_hash) { {:EXPECTED_TYPE => "String", :ACTUAL_TYPE => "Fixnum" } }

          it "uses the key ACTUAL_TYPE" do
             expect(subject.as_json).to eq(expected_hash)
          end
        end

      end
    end
  end
end