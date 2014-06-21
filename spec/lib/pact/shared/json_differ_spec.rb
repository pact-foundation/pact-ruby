require 'spec_helper'
require 'pact/shared/json_differ'

module Pact
  describe JsonDiffer do

    describe ".call" do

      let(:expected) { {a: 'b'}}
      let(:actual) { {a: 'c'}}
      let(:difference) { {a: Pact::Matchers::Difference.new('b', 'c')} }
      it "returns a diff" do
        expect(JsonDiffer.call(expected, actual)).to eq(difference)
      end

    end

  end
end
