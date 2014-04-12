require 'spec_helper'
require 'pact/matchers/unexpected_index'

module Pact
  describe UnexpectedIndex do

    describe "#as_json" do
      it "returns a string representation of the object" do
        expect(subject.as_json).to eq subject.to_s
      end
    end

    describe "#to_json" do
      it "serialises the object to JSON" do
        expect(subject.to_json).to eq "\"#{subject.to_s}\""
      end
    end

  end
end