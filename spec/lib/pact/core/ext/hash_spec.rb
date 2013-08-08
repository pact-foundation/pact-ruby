require 'spec_helper'
require 'pact/term'

describe 'Hash extension' do

  describe 'diffing' do

    context 'where an expected value is a non-empty string' do

      subject { {:a => 'a', :b => 'b'} }

      context 'and the actual value is an empty string' do

        let(:actual) { {:a => 'a', :b => ''} }

        it 'includes this in the diff' do
          expect(subject.diff_with_actual(actual)).to eql({:b => {:expected => 'b', :actual => ''}})
        end

      end

    end

    context "when the expected value is a hash" do
      subject { {a: 'b'} }
      context "when the actual value is an array" do
        let(:actual) { [1] }
        let(:diff) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(subject.diff_with_actual(actual)).to eql(diff)
        end
      end
      context "when the actual value is an hash" do
        let(:actual) { {b: 'c'} }
        let(:diff) { { a: {expected:"b", actual: nil}} }
        it "should return the diff" do
          expect(subject.diff_with_actual(actual)).to eql(diff)
        end
      end
      context "when the actual value is an number" do
        let(:actual) { 1 }
        let(:diff) { {expected: {a: "b"}, actual: 1} }
        it "should return the diff" do
          expect(subject.diff_with_actual(actual)).to eql(diff)
        end
      end
      context "when the actual value is a string" do
        let(:actual) { "Thing" }
        let(:diff) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(subject.diff_with_actual(actual)).to eql(diff)
        end
      end
      context "when the actual value is the same" do
        let (:actual) { {a: 'b'} }
        it "should return an empty hash" do
          expect(subject.diff_with_actual(actual)).to eql({})
        end
      end
    end

    context "when the expected value is an array" do
      subject { [1] }
      context "when the actual value is an array" do
        let(:actual) { [2] }
        let(:diff) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(subject.diff_with_actual(actual)).to eql(diff)
        end
      end
      context "when the actual value is an hash" do
        let(:actual) { {b: 'c'} }
        let(:diff) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(subject.diff_with_actual(actual)).to eql(diff)
        end
      end
      context "when the actual value is an number" do
        let(:actual) { 1 }
        let(:diff) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(subject.diff_with_actual(actual)).to eql(diff)
        end
      end
      context "when the actual value is a string" do
        let(:actual) { "Thing" }
        let(:diff) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(subject.diff_with_actual(actual)).to eql(diff)
        end
      end
      context "when the actual value is the same" do
        let (:actual) { [1] }
        it "should return an empty hash" do
          expect(subject.diff_with_actual(actual)).to eql({})
        end
      end
    end

    context "when the expected value is a string" do
      subject { "Thing"}
      context "when the actual value is an array" do
        let(:actual) { [2] }
        let(:diff) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(subject.diff_with_actual(actual)).to eql(diff)
        end
      end
      context "when the actual value is an hash" do
        let(:actual) { {b: 'c'} }
        let(:diff) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(subject.diff_with_actual(actual)).to eql(diff)
        end
      end
      context "when the actual value is an number" do
        let(:actual) { 1 }
        let(:diff) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(subject.diff_with_actual(actual)).to eql(diff)
        end
      end
      context "when the actual value is a string" do
        let(:actual) { "Another Thing" }
        let(:diff) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(subject.diff_with_actual(actual)).to eql(diff)
        end
      end
      context "when the actual value is the same" do
        let (:actual) { "Thing" }
        it "should return an empty hash" do
          expect(subject.diff_with_actual(actual)).to eql({})
        end
      end
    end

    context "when the expected value is a number" do
      subject { 1 }
      let(:diff) { {expected: subject, actual: actual} }
      context "when the actual value is an array" do
        let(:actual) { [2] }
        it "should return the diff" do
          expect(subject.diff_with_actual(actual)).to eql(diff)
        end
      end
      context "when the actual value is an hash" do
        let(:actual) { {b: 'c'} }
        it "should return the diff" do
          expect(subject.diff_with_actual(actual)).to eql(diff)
        end
      end
      context "when the actual value is an number" do
        let(:actual) { 2 }
        it "should return the diff" do
          expect(subject.diff_with_actual(actual)).to eql(diff)
        end
      end
      context "when the actual value is a string" do
        let(:actual) { "Another Thing" }
        it "should return the diff" do
          expect(subject.diff_with_actual(actual)).to eql(diff)
        end
      end
      context "when the actual value is the same" do
        let (:actual) { 1 }
        it "should return an empty hash" do
          expect(subject.diff_with_actual(actual)).to eql({})
        end
      end
    end

    context "when the expected value is a String matcher" do
      
    end

    context "when the expected value is a Number matcher" do
      
    end
    context "when the expected value is an array with a matcher" do
      
    end
    context "when the expected value is a hash with a matcher" do
      
    end


    context "where a Pact::Term is found that matches the actual value" do
      subject { {:a => Pact::Term.new(:matcher => /a/)} }
      let(:actual) { {:a => "apple" } }

      it 'does not include this in the diff' do
        expect(subject.diff_with_actual(actual)).to eql({})
      end
    end

    context "where an array is expected at a key inside a hash, but a hash is found" do
      subject { {:a => [1,2,3]} }
      let(:actual) { {:a => {:b => 1} } }

      it 'includes this in the diff' do
        expect(subject.diff_with_actual(actual)).to eql({:a => {:expected => [1,2,3], :actual => {:b => 1}}})
      end
    end

    context "where an array is expected, but a hash is found" do
      subject { {:a => :b} }
      let(:actual) { [4,5,6] }

      it 'includes this in the diff' do
        expect(subject.diff_with_actual(actual)).to eql({:expected => {:a => :b}, :actual => [4,5,6] })
      end
    end

    context "where a hash is expected, but array is found" do
      subject { [4,5,6] }
      let(:actual) { {:a => :b} }

      it 'includes this in the diff' do
        expect(subject.diff_with_actual(actual)).to eql({:expected => [4,5,6], :actual => {:a => :b} })
      end
    end

    context "when two different arrays are found" do
      subject { [4,5,6] }
      let(:actual) { [5,6,7] }

      it 'includes this in the diff' do
        expect(subject.diff_with_actual(actual)).to eql({:expected => [4,5,6], :actual => [5,6,7] })
      end
    end

    context "when an array that matches the Pact::Term is found" do
      subject { [Pact::Term.new(:matcher => /4/),"5","6"] }
      let(:actual) { ["4","5","6"] }

      it 'includes this in the diff' do
        expect(subject.diff_with_actual(actual)).to eql({})
      end
    end

  end

end