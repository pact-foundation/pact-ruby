require 'spec_helper'

module Pact
  describe Term do

    describe "equality" do
      context "when the matcher and generate attrs are the same" do
        let(:this) { Term.new(generate: 'A', matcher: /A/) }
        let(:that) { Term.new(generate: 'A', matcher: /A/) }

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

      context "when the matcher attrs are different" do
        let(:this) { Term.new(matcher: 'A') }
        let(:that) { Term.new(matcher: 'B') }

        it "is not equal" do
          expect(this).to_not eq that
        end
      end
    end

  end
end
