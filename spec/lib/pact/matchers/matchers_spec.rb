require 'spec_helper'
require 'pact/term'
require 'pact/something_like'
require 'pact/matchers'

describe Pact::Matchers do
  include Pact::Matchers

  describe 'matching with something like' do

    context 'when the actual is something like the expected' do
      let(:expected) { Pact::SomethingLike.new( { a: 1 } ) }
      let(:actual) { { a: 2} }

      it 'returns an empty diff' do
        expect(diff(expected, actual)).to eq({})
      end

    end

  end

  describe 'option {allow_unexpected_keys: false}' do
    context "when an unexpected key is found" do
      let(:expected) { {:a => 1} }
      let(:actual) { {:a => 1, :b => 2} }
      let(:difference) { {:b => {:expected => Pact::UnexpectedKey.new, :actual => 2 }} }
      it "returns it in the diff" do
        expect(diff(expected, actual, allow_unexpected_keys: false)).to eq difference
      end
    end
  end

  describe "expecting key to be present with nil value and not finding key" do
    let(:expected) { {a: nil} }
    let(:actual) { {} }
    let(:difference) { {a: {expected: nil, actual: Pact::KeyNotFound.new }} }
    it "returns the key in the diff" do
      expect(diff(expected, actual)).to eq difference
    end
  end

  describe 'structure_diff' do
    let(:expected) {
      {a: 'a string', b: 1, c: nil, d: [{e: 'thing'}], f: {g: 10}, h: false}
    }

    context "when the classes match" do
      let(:actual) { {a: 'another string', b: 2, c: nil, d: [{e: 'something'}], f: {g: 100}, h: true} }
      let(:difference) { {} }
      it "returns an empty hash" do
        expect(structure_diff(expected, actual)).to eq difference
      end
    end

    context "when a key is not found" do
      let(:actual) { {a: 'blah'} }
      let(:expected) { {b: 'blah'} }
      let(:difference) { {:b=>{:expected=>{:class=>String, :eg=>"blah"}, :actual=>Pact::KeyNotFound.new}} }
      it "returns the difference" do
        expect(structure_diff(expected, actual)).to eq difference
      end
    end

    context "when a number is expected" do
      let(:expected) { {a: 1} }
      #let(:difference) { {a: {expected: 'Fixnum (eg. 1)', actual: 'String ("a string")'}}  }
      let(:difference) { {a: {expected: {:class => Fixnum, eg: 1 } , actual: {:class => String, :value => 'a string'}}}  }

      context "and a string is found" do
        let(:actual) { {a: 'a string'}}
        it "returns the diff" do
          expect(structure_diff(expected, actual)).to eq difference
        end
      end
      context "and nil is found" do
        let(:actual) { {a: nil}}
        let(:difference ) { {a: {:expected => {:class => Fixnum, eg: 1}, :actual => nil} } }
        it "returns the diff" do
          expect(structure_diff(expected, actual)).to eq difference
        end
      end
      context "and a hash is found" do
        let(:actual) { {a: {b: 1}} }
        let(:difference) { {:a=>{:expected=>{:class=>Fixnum, :eg=>1}, :actual=>{:class=>Hash, :value=>{:b=>1}}}} }
        it "returns the diff" do
          expect(structure_diff(expected, actual)).to eq difference
        end
      end
      context "and an array is found" do
        let(:actual) { {a: [1] } }
        let(:difference) { {:a=>{:expected=>{:class=>Fixnum, :eg=>1}, :actual=>{:class=>Array, :value=>[1]}}} }
        it "returns the diff" do
          expect(structure_diff(expected, actual)).to eq difference
        end
      end
    end

    context "when an array is expected" do
      let(:expected) { [{name: 'Fred'}, {name: 'Mary'}] }
      context "when an item with differing class values is found" do
        let(:actual) { [{name: 'Fred'}, {name: 1}] }
        let(:difference) { [
          Pact::Matchers::NO_DIFF_INDICATOR,
           {:name => {
                :expected=> { :class=>String, :eg=>"Mary" },
                :actual=> { :class=>Fixnum, :value=>1} }
            }
          ]
        }
        it "returns the diff" do
          expect(structure_diff(expected, actual)).to eq difference
        end
      end
    end


    context "when nil is expected" do
      let(:expected) { {a: nil} }
      context "and a string is found" do
        let(:actual) { {a: 'a string'} }
        let(:difference) { {:a=>{:expected=>nil, :actual=>{:class=>String, :value=>"a string"}}} }
        it "returns the diff" do
          expect(structure_diff(expected, actual)).to eq difference
        end
      end
    end

    context "when a term is expected" do
      let(:expected) { {a: Pact::Term.new(:matcher => /p/, :generate => 'apple')} }
      context "and a non matching string is found" do
        let(:actual) { {a: 'banana'} }
        let(:difference) { {:a=>{:expected=>/p/, :actual=>"banana"}} }
        it "returns the diff" do
          expect(structure_diff(expected, actual)).to eq difference
        end
      end
    end
  end

  describe 'diffing' do

    context "when expected is longer than the actual" do
      subject { [1,2,3] }
      let(:actual) { [1,2]}
      let(:difference) { [Pact::Matchers::NO_DIFF_INDICATOR, Pact::Matchers::NO_DIFF_INDICATOR, {expected: 3, actual: Pact::IndexNotFound.new}] }
      it 'returns the diff' do
        expect(diff(subject, actual)).to eq(difference)
      end
    end

    context "when actual array is longer than the expected" do
      subject { [1] }
      let(:actual) { [1,2]}
      let(:difference) { [Pact::Matchers::NO_DIFF_INDICATOR, {expected: Pact::UnexpectedIndex.new , actual: 2}] }
      it 'returns the diff' do
        expect(diff(subject, actual)).to eq(difference)
      end      
    end

    context 'where an expected value is a non-empty string' do

      subject { {:a => 'a', :b => 'b'} }

      context 'and the actual value is an empty string' do

        let(:actual) { {:a => 'a', :b => ''} }

        it 'includes this in the diff' do
          expect(diff(subject, actual)).to eql({:b => {:expected => 'b', :actual => ''}})
        end

      end

    end

    context "when the expected value is a hash" do
      subject { {a: 'b'} }
      context "when the actual value is an array" do
        let(:actual) { [1] }
        let(:difference) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(diff(subject, actual)).to eql(difference)
        end
      end
      context "when the actual value is an hash" do
        let(:actual) { {b: 'c'} }
        let(:difference) { { a: {expected:"b", actual: Pact::KeyNotFound.new}} }
        it "should return the diff" do
          expect(diff(subject, actual)).to eql(difference)
        end
      end
      context "when the actual value is an number" do
        let(:actual) { 1 }
        let(:difference) { {expected: {a: "b"}, actual: 1} }
        it "should return the diff" do
          expect(diff(subject, actual)).to eql(difference)
        end
      end
      context "when the actual value is a string" do
        let(:actual) { "Thing" }
        let(:difference) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(diff(subject, actual)).to eql(difference)
        end
      end
      context "when the actual value is the same" do
        let (:actual) { {a: 'b'} }
        it "should return an empty hash" do
          expect(diff(subject, actual)).to eql({})
        end
      end
    end

    context "when the expected value is an array" do
      subject { [1] }
      context "when the actual value is an array" do
        let(:actual) { [2] }
        let(:difference) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(diff(subject, actual)).to eql([{expected: 1, actual: 2}])
        end
      end
      context "when the actual value is an hash" do
        let(:actual) { {b: 'c'} }
        let(:difference) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(diff(subject, actual)).to eql(difference)
        end
      end
      context "when the actual value is an number" do
        let(:actual) { 1 }
        let(:difference) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(diff(subject, actual)).to eql(difference)
        end
      end
      context "when the actual value is a string" do
        let(:actual) { "Thing" }
        let(:difference) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(diff(subject, actual)).to eql(difference)
        end
      end
      context "when the actual value is the same" do
        let (:actual) { [1] }
        it "should return an empty hash" do
          expect(diff(subject, actual)).to eql({})
        end
      end
    end

    context "when the expected value is a string" do
      subject { "Thing"}
      context "when the actual value is an array" do
        let(:actual) { [2] }
        let(:difference) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(diff(subject, actual)).to eql(difference)
        end
      end
      context "when the actual value is an hash" do
        let(:actual) { {b: 'c'} }
        let(:difference) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(diff(subject, actual)).to eql(difference)
        end
      end
      context "when the actual value is an number" do
        let(:actual) { 1 }
        let(:difference) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(diff(subject, actual)).to eql(difference)
        end
      end
      context "when the actual value is a string" do
        let(:actual) { "Another Thing" }
        let(:difference) { {expected: subject, actual: actual} }
        it "should return the diff" do
          expect(diff(subject, actual)).to eql(difference)
        end
      end
      context "when the actual value is the same" do
        let (:actual) { "Thing" }
        it "should return an empty hash" do
          expect(diff(subject, actual)).to eql({})
        end
      end
    end

    context "when the expected value is a number" do
      subject { 1 }
      let(:difference) { {expected: subject, actual: actual} }
      context "when the actual value is an array" do
        let(:actual) { [2] }
        it "should return the diff" do
          expect(diff(subject, actual)).to eql(difference)
        end
      end
      context "when the actual value is an hash" do
        let(:actual) { {b: 'c'} }
        it "should return the diff" do
          expect(diff(subject, actual)).to eql(difference)
        end
      end
      context "when the actual value is an number" do
        let(:actual) { 2 }
        it "should return the diff" do
          expect(diff(subject, actual)).to eql(difference)
        end
      end
      context "when the actual value is a string" do
        let(:actual) { "Another Thing" }
        it "should return the diff" do
          expect(diff(subject, actual)).to eql(difference)
        end
      end
      context "when the actual value is the same" do
        let (:actual) { 1 }
        it "should return an empty hash" do
          expect(diff(subject, actual)).to eql({})
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

    context "when an expected value is nil but not nil is found" do
      subject { {a: nil} }
      let(:actual) { {a: 'blah'} }
      let(:difference) { {:a=>{:expected=>nil, :actual=>"blah"}} }
      it "should return the diff" do
        expect(diff(subject, actual)).to eql(difference)
      end
    end

    context "a deep mismatch" do
      subject { {a:  {b: { c: [1,2]}, d: { e: Pact::Term.new(matcher: /a/, generate: 'apple')}}, f: 1, g: {h: 99}} }
      let(:actual) { {a:  {b: { c: [1,2]}, d: { e: 'food'}}, f: "thing"} }
      let(:difference) { {:a=>{:d=>{:e=>{:expected=>/a/, :actual=>"food"}}}, :f=>{:expected=>1, :actual=>"thing"}, :g=>{:expected=>{:h=>99}, :actual=> Pact::KeyNotFound.new}} }

      it 'should return the diff' do
        expect(diff(subject, actual)).to eq(difference)
      end
    end


    context "where a Pact::Term is found that matches the actual value" do
      subject { {:a => Pact::Term.new(:matcher => /a/, :generate => 'apple')} }
      let(:actual) { {:a => "apple" } }

      it 'does not include this in the diff' do
        expect(diff(subject, actual)).to eq({})
      end
    end

    context "where an array is expected at a key inside a hash, but a hash is found" do
      subject { {:a => [1,2,3]} }
      let(:actual) { {:a => {:b => 1} } }

      it 'includes this in the diff' do
        expect(diff(subject, actual)).to eql({:a => {:expected => [1,2,3], :actual => {:b => 1}}})
      end
    end

    context "where an array is expected, but a hash is found" do
      subject { {:a => :b} }
      let(:actual) { [4,5,6] }

      it 'includes this in the diff' do
        expect(diff(subject, actual)).to eq({:expected => {:a => :b}, :actual => [4,5,6] })
      end
    end

    context "where a hash is expected, but array is found" do
      subject { [4,5,6] }
      let(:actual) { {:a => :b} }

      it 'includes this in the diff' do
        expect(diff(subject, actual)).to eq({:expected => [4,5,6], :actual => {:a => :b} })
      end
    end

    context "when two different arrays are found" do
      subject { [4,5,6] }
      let(:actual) { [4,6,7] }
      let(:difference) { [Pact::Matchers::NO_DIFF_INDICATOR, {:expected=>5, :actual=>6}, {:expected=>6, :actual=>7}] }

      it 'includes this in the diff' do
        expect(diff(subject, actual)).to eq(difference)
      end
    end

    context "when an array that matches the Pact::Term is found" do
      subject { [Pact::Term.new(:matcher => /4/, :generate => '4'),"5","6"] }
      let(:actual) { ["4","5","6"] }

      it 'includes this in the diff' do
        expect(diff(subject, actual)).to eq({})
      end
    end

  end

end