require 'spec_helper'
require 'pact/matchers'
require 'pact/consumer_contract/headers'

module Pact::Matchers

  describe Pact::Matchers do
    include Pact::Matchers

    # TODO this is an integration test
    describe 'matching headers' do
      let(:expected) { Pact::Headers.new('Content-Type' => 'application/hippo')}

      context "when the headers match in a case insensitive way" do

        context "when the values match" do
          let(:actual) { Pact::Headers.new('CONTENT-TYPE' => 'application/hippo')}
          it "returns an empty diff" do
            expect(diff(expected, actual)).to be_empty
          end
        end

        context "when the header values do not match" do
          let(:actual) { Pact::Headers.new('CONTENT-TYPE' => 'application/alligator')}
          let(:difference) { {"Content-Type" => Difference.new('application/hippo', 'application/alligator')} }
          it "returns the diff" do
            expect(diff(expected, actual)).to eq difference
          end
        end
      end

      context "when the headers do not match" do

        let(:actual) { Pact::Headers.new('Content-Length' => '1')}
        let(:difference) { {"Content-Type" => Difference.new('application/hippo', Pact::KeyNotFound.new)} }
        it "returns a diff" do
          expect(diff(expected, actual)).to eq difference
        end

      end

    end

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
        let(:difference) { {:b => Difference.new(Pact::UnexpectedKey.new, 2 )} }
        it "returns it in the diff" do
          expect(diff(expected, actual, allow_unexpected_keys: false)).to eq difference
        end
      end
    end

    describe "expecting key to be present with nil value and not finding key" do
      let(:expected) { {a: nil} }
      let(:actual) { {} }
      let(:difference) { {a: Difference.new(nil, Pact::KeyNotFound.new )} }
      it "returns the key in the diff" do
        expect(diff(expected, actual)).to eq difference
      end
    end

    describe "expecting a string matching a regexp and not finding key" do
      let(:expected) { {a: /b/} }
      let(:actual) { {} }
      let(:difference) { {:a=> RegexpDifference.new(/b/, Pact::KeyNotFound.new) } }
      it "returns the diff" do
        expect(diff(expected, actual)).to eq difference
      end
    end

    describe 'type_diff' do
      let(:expected) {
        {a: 'a string', b: 1, c: nil, d: [{e: 'thing'}], f: {g: 10}, h: false}
      }

      context "when the classes match" do
        let(:actual) { {a: 'another string', b: 2, c: nil, d: [{e: 'something'}], f: {g: 100}, h: true} }
        let(:difference) { {} }
        it "returns an empty hash" do
          expect(type_diff(expected, actual)).to eq difference
        end
      end

      context "when a key is not found" do
        let(:actual) { {a: 'blah'} }
        let(:expected) { {b: 'blah'} }
        let(:difference) { {:b=>TypeDifference.new(Pact::ExpectedType.new("blah"), Pact::KeyNotFound.new)} }
        it "returns the difference" do
          expect(type_diff(expected, actual)).to eq difference
        end
      end

      context "when a number is expected" do
        let(:expected) { {a: 1} }
        let(:difference) { {a: TypeDifference.new(Pact::ExpectedType.new(1) , Pact::ActualType.new('a string'))}  }

        context "and a string is found" do
          let(:actual) { {a: 'a string'}}
          it "returns the diff" do
            expect(type_diff(expected, actual)).to eq difference
          end
        end
        context "and nil is found" do
          let(:actual) { {a: nil}}
          let(:difference ) { {a: TypeDifference.new(Pact::ExpectedType.new(1), Pact::ActualType.new(nil)) } }
          it "returns the diff" do
            expect(type_diff(expected, actual)).to eq difference
          end
        end
        context "and a hash is found" do
          let(:actual) { {a: {b: 1}} }
          let(:difference) { {:a=>TypeDifference.new(Pact::ExpectedType.new(1), Pact::ActualType.new({:b=>1})) } }
          it "returns the diff" do
            expect(type_diff(expected, actual)).to eq difference
          end
        end
        context "and an array is found" do
          let(:actual) { {a: [1] } }
          let(:difference) { {:a=>TypeDifference.new(Pact::ExpectedType.new(1), Pact::ActualType.new([1]))}}
          it "returns the diff" do
            expect(type_diff(expected, actual)).to eq difference
          end
        end
      end

      context "when an array is expected" do
        let(:expected) { [{name: 'Fred'}, {name: 'Mary'}] }
        context "when an item with differing class values is found" do
          let(:actual) { [{name: 'Fred'}, {name: 1}] }
          let(:difference) { [
            Pact::Matchers::NO_DIFF_INDICATOR,
             {:name =>
                  TypeDifference.new(Pact::ExpectedType.new("Mary"), Pact::ActualType.new(1))
              }
            ]
          }
          it "returns the diff" do
            expect(type_diff(expected, actual)).to eq difference
          end
        end
      end


      context "when nil is expected" do
        let(:expected) { {a: nil} }
        context "and a string is found" do
          let(:actual) { {a: 'a string'} }
          let(:difference) { {:a=>TypeDifference.new(Pact::ExpectedType.new(nil), Pact::ActualType.new("a string")) } }
          it "returns the diff" do
            expect(type_diff(expected, actual)).to eq difference
          end
        end
      end

      context "when a term is expected" do
        let(:expected) { {a: Pact::Term.new(:matcher => /p/, :generate => 'apple')} }
        context "and a non matching string is found" do
          let(:actual) { {a: 'banana'} }
          let(:difference) { {:a=>Pact::Matchers::RegexpDifference.new(/p/,"banana")} }
          it "returns the diff" do
            expect(type_diff(expected, actual)).to eq difference
          end
        end
      end

      context "when a term is expected inside a missing hash" do
        let(:expected) { {a: {b: Pact::Term.new(:matcher => /p/, :generate => 'apple')}} }
        context "and a non matching value is found" do
          let(:actual) { {a: nil} }
          let(:difference) { {a: Difference.new({b: /p/}, nil)} }
          it "returns the diff with the regexp unpacked" do
            expect(type_diff(expected, actual)).to eq difference
          end
        end
      end

      context "when unexpected keys are allowed" do
        let(:expected) { { a: 'b' } }
        let(:actual) { {a: 'c', d: 'e'} }
        let(:difference) { {} }
        it "returns the diff" do
          expect(type_diff(expected, actual, allow_unexpected_keys: true)).to eq difference
        end
      end

      context "when unexpected keys are not allowed" do
        let(:expected) { { a: 'b' } }
        let(:actual) { {a: 'c', d: 'e'} }
        let(:difference) { {d: Difference.new(Pact::UnexpectedKey.new, 'e')} }
        it "returns the diff" do
          expect(type_diff(expected, actual, allow_unexpected_keys: false)).to eq difference
        end
      end
    end

    describe 'diffing' do

      context "when expected is longer than the actual" do
        subject { [1,2,3] }
        let(:actual) { [1,2]}
        let(:difference) { [Pact::Matchers::NO_DIFF_INDICATOR, Pact::Matchers::NO_DIFF_INDICATOR, Difference.new(3, Pact::IndexNotFound.new)] }
        it 'returns the diff' do
          expect(diff(subject, actual)).to eq(difference)
        end
      end

      context "when the different index is in the middle of an array" do
        subject { [1,2,3] }
        let(:actual) { [1,7,3]}
        let(:difference) { [Pact::Matchers::NO_DIFF_INDICATOR, Difference.new(2, 7), Pact::Matchers::NO_DIFF_INDICATOR] }
        it 'returns the diff' do
          expect(diff(subject, actual)).to eq(difference)
        end
      end

      context "when actual array is longer than the expected" do
        subject { [1] }
        let(:actual) { [1,2]}
        let(:difference) { [Pact::Matchers::NO_DIFF_INDICATOR, Difference.new(Pact::UnexpectedIndex.new, 2)] }
        it 'returns the diff' do
          expect(diff(subject, actual)).to eq(difference)
        end
      end

      context 'where an expected value is a non-empty string' do

        subject { {:a => 'a', :b => 'b'} }

        context 'and the actual value is an empty string' do

          let(:actual) { {:a => 'a', :b => ''} }

          it 'includes this in the diff' do
            expect(diff(subject, actual)).to eq({:b => Difference.new('b', '')})
          end

        end

      end

      context "when the expected value is a hash" do
        subject { {a: 'b'} }
        context "when the actual value is an array" do
          let(:actual) { [1] }
          let(:difference) { Difference.new(subject, actual) }
          it "should return the diff" do
            expect(diff(subject, actual)).to eq(difference)
          end
        end
        context "when the actual value is an hash" do
          let(:actual) { {b: 'c'} }
          let(:difference) { { a: Difference.new("b",Pact::KeyNotFound.new)} }
          it "should return the diff" do
            expect(diff(subject, actual)).to eq(difference)
          end
        end
        context "when the actual value is an number" do
          let(:actual) { 1 }
          let(:difference) { Difference.new({a: "b"}, 1)  }
          it "should return the diff" do
            expect(diff(subject, actual)).to eq(difference)
          end
        end
        context "when the actual value is a string" do
          let(:actual) { "Thing" }
          let(:difference) { Difference.new(subject, actual) }
          it "should return the diff" do
            expect(diff(subject, actual)).to eq(difference)
          end
        end
        context "when the actual value is the same" do
          let (:actual) { {a: 'b'} }
          it "should return an empty hash" do
            expect(diff(subject, actual)).to eq({})
          end
        end
      end

      context "when the expected value is an array" do
        subject { [1] }
        context "when the actual value is an array" do
          let(:actual) { [2] }
          let(:difference) { [Difference.new(1, 2)] }
          it "should return the diff" do
            expect(diff(subject, actual)).to eq difference
          end
        end
        context "when the actual value is an hash" do
          let(:actual) { {b: 'c'} }
          let(:difference) { Difference.new(subject, actual) }
          it "should return the diff" do
            expect(diff(subject, actual)).to eq(difference)
          end
        end
        context "when the actual value is an number" do
          let(:actual) { 1 }
          let(:difference) { Difference.new(subject, actual) }
          it "should return the diff" do
            expect(diff(subject, actual)).to eq(difference)
          end
        end
        context "when the actual value is a string" do
          let(:actual) { "Thing" }
          let(:difference) { Difference.new(subject, actual) }
          it "should return the diff" do
            expect(diff(subject, actual)).to eq(difference)
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
          let(:difference) { Difference.new(subject, actual) }
          it "should return the diff" do
            expect(diff(subject, actual)).to eq(difference)
          end
        end
        context "when the actual value is an hash" do
          let(:actual) { {b: 'c'} }
          let(:difference) { Difference.new(subject, actual) }
          it "should return the diff" do
            expect(diff(subject, actual)).to eq(difference)
          end
        end
        context "when the actual value is an number" do
          let(:actual) { 1 }
          let(:difference) { Difference.new(subject, actual) }
          it "should return the diff" do
            expect(diff(subject, actual)).to eq(difference)
          end
        end
        context "when the actual value is a string" do
          let(:actual) { "Another Thing" }
          let(:difference) { Difference.new(subject, actual) }
          it "should return the diff" do
            expect(diff(subject, actual)).to eq(difference)
          end
        end
        context "when the actual value is the same" do
          let (:actual) { "Thing" }
          it "should return an empty hash" do
            expect(diff(subject, actual)).to eq({})
          end
        end
      end

      context "when the expected value is a number" do
        subject { 1 }
        let(:difference) { Difference.new(subject, actual) }
        context "when the actual value is an array" do
          let(:actual) { [2] }
          it "should return the diff" do
            expect(diff(subject, actual)).to eq(difference)
          end
        end
        context "when the actual value is an hash" do
          let(:actual) { {b: 'c'} }
          it "should return the diff" do
            expect(diff(subject, actual)).to eq(difference)
          end
        end
        context "when the actual value is an number" do
          let(:actual) { 2 }
          it "should return the diff" do
            expect(diff(subject, actual)).to eq(difference)
          end
        end
        context "when the actual value is a string" do
          let(:actual) { "Another Thing" }
          it "should return the diff" do
            expect(diff(subject, actual)).to eq(difference)
          end
        end
        context "when the actual value is the same" do
          let (:actual) { 1 }
          it "should return an empty hash" do
            expect(diff(subject, actual)).to eq({})
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
        let(:difference) { {:a=>Difference.new(nil, "blah")} }
        it "should return the diff" do
          expect(diff(subject, actual)).to eq(difference)
        end
      end

      context "a deep mismatch" do
        subject { {a:  {b: { c: [1,2]}, d: { e: Pact::Term.new(matcher: /a/, generate: 'apple')}}, f: 1, g: {h: 99}} }
        let(:actual) { {a:  {b: { c: [1,2]}, d: { e: 'food'}}, f: "thing"} }
        let(:difference) { {:a=>{:d=>{:e=> RegexpDifference.new(/a/, "food")}},
          :f=> Difference.new(1, "thing"),
          :g=>Difference.new({:h=>99}, Pact::KeyNotFound.new)} }

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
          expect(diff(subject, actual)).to eq({:a => Difference.new([1,2,3], {:b => 1})})
        end
      end

      context "where an array is expected, but a hash is found" do
        subject { {:a => :b} }
        let(:actual) { [4,5,6] }

        it 'includes this in the diff' do
          expect(diff(subject, actual)).to eq(Difference.new({:a => :b}, [4,5,6] ))
        end
      end

      context "where a hash is expected, but array is found" do
        subject { [4,5,6] }
        let(:actual) { {:a => :b} }

        it 'includes this in the diff' do
          expect(diff(subject, actual)).to eq(Difference.new([4,5,6],{:a => :b}))
        end
      end

      context "when two different arrays are found" do
        subject { [4,5,6] }
        let(:actual) { [4,6,7] }
        let(:difference) { [Pact::Matchers::NO_DIFF_INDICATOR, Difference.new(5, 6), Difference.new(6, 7)] }

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
end