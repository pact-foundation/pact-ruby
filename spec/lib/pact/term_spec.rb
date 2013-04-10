require 'spec_helper'

module Pact
  describe Term do

    describe "equality" do
      context "when the match and generate attrs are the same" do
        let(:this) { Term.new(generate: 'A', match: /A/) }
        let(:that) { Term.new(generate: 'A', match: /A/) }

        it "is equal" do
          expect(this).to eq that
        end
      end

      context "when the generate attrs are different" do
        let(:this) { Term.new(generate: /A/) }
        let(:that) { Term.new(generate: /B/) }

        it "is not equal" do
          expect(this).to_not eq that
        end
      end

      context "when the match attrs are different" do
        let(:this) { Term.new(match: 'A') }
        let(:that) { Term.new(match: 'B') }

        it "is not equal" do
          expect(this).to_not eq that
        end
      end
    end

  end
end
