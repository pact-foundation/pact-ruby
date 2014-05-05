require 'spec_helper'

module Pact
  describe Term do

    describe 'initialize' do
      let(:matcher) { /e/ }
      let(:generate) { 'apple'}
      subject { Term.new(generate: generate, matcher: matcher) }
      context "when a matcher and generate are specified" do
        context "when the matcher matches the generated value" do
          it 'does not raise an exception' do
            subject
          end
        end

        context "when the matcher does not match the generated value" do
          let(:generate) { 'banana' }
          it 'raises an exception' do
            expect { subject }.to raise_error /does not match/
          end
        end
      end
      context 'when a matcher is not specified' do
        let(:matcher) { nil }
        it 'raises an exception' do
          expect { subject }.to raise_error /Please specify a matcher/
        end
      end
      context 'when a generate is not specified' do
        let(:generate) { nil }
        it 'raises an exception' do
          expect { subject }.to raise_error /Please specify a value/
        end
      end
    end

    describe "equality" do
      context "when the matcher and generate attrs are the same" do
        let(:this) { Term.new(generate: 'A', matcher: /A/) }
        let(:that) { Term.new(generate: 'A', matcher: /A/) }

        it "is equal" do
          expect(this).to eq that
        end
      end

      context "when the generate attrs are different" do
        let(:this) { Term.new(generate: 'A', matcher: /.*/) }
        let(:that) { Term.new(generate: 'B', matcher: /.*/) }

        it "is not equal" do
          expect(this).to_not eq that
        end
      end

      context "when the matcher attrs are different" do
        let(:this) { Term.new(matcher: /A/, generate: 'AB') }
        let(:that) { Term.new(matcher: /B/, generate: 'AB') }

        it "is not equal" do
          expect(this).to_not eq that
        end
      end
    end

    describe 'empty?' do

      subject { Term.new(generate: 'some', matcher: /some/) }

      it 'should return false' do
        expect(subject).to_not be_empty
      end

    end

    describe 'unpack_regexps' do
      let(:term) { Term.new(generate: 'some', matcher: /s/) }
      let(:body) { [{a: [{b: term}], c:term, d: 1, e: 'blah'}] }
      let(:expected) { [{:a=>[{:b=>/s/}], :c=>/s/, :d=>1, :e=>"blah"}] }

      it "returns a structure with the Pact::Terms replaced by their regexps" do
        expect(Term.unpack_regexps(body)).to eq expected
      end

    end

  end
end
