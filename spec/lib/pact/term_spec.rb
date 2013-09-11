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

    describe 'empty?' do

      subject { Term.new(generate: generate, matcher: /some matcher/) }

      context 'with generate' do

        let(:generate) { 'generate here'}

        it 'is not empty' do
          expect(subject).to_not be_empty
        end

      end

      context 'without generate' do

        let(:generate) { nil }

        it 'is empty' do
          expect(subject).to be_empty
        end
      end

    end

  end
end
