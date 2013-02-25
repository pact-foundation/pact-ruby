require 'spec_helper'

module Pact
  module Consumer
    describe GenerateResponse do

      let(:response_spec) do
        {
          woot: /x/,
          britney: 'britney',
          nested: { foo: /bar/, baz: 'qux' },
          array: ['first', /second/]
        }
      end

      describe "from response specification" do

        subject { GenerateResponse.from_specification(response_spec) }

        it "converts regexes into real data" do
          expect(subject[:woot]).to eql 'x'
        end

        it "passes strings through" do
          expect(subject[:britney]).to eql 'britney'
        end

        it "handles nested hashes" do
          expect(subject[:nested]).to eql({ foo: 'bar', baz: 'qux' })
        end

        it "handles arrays" do
          expect(subject[:array]).to eql ['first', 'second']
        end

      end

    end
  end
end
