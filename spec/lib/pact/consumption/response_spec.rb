require 'spec_helper'

module Pact
  module Consumption
    describe Response do

      subject do
        Response.new({
          woot: /x/, britney: 'britney',
          nested: { foo: /bar/, baz: 'qux' },
          array: ['first', /second/]
        })
      end

      describe "reify" do

        it "converts regexes into real data" do
          expect(subject.reify[:woot]).to eql 'x'
        end

        it "passes strings through" do
          expect(subject.reify[:britney]).to eql 'britney'
        end

        it "handles nested hashes" do
          expect(subject.reify[:nested]).to eql({ foo: 'bar', baz: 'qux' })
        end

        it "handles arrays" do
          expect(subject.reify[:array]).to eql ['first', 'second']
        end

      end

    end
  end
end
