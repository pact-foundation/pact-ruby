require 'spec_helper'

module Pact
  module Consumption
    describe Response do

      subject { Response.new({ woot: /x/, britney: 'britney', nested: { foo: /bar/, baz: 'qux' }, array: ['first', /second/]} ) }

      describe "reify" do

        it "converts regexes into real data" do
          subject.reify[:woot].should == 'x'
        end

        it "passes strings through" do
          subject.reify[:britney].should == 'britney'
        end

        it "handles nested hashes" do
          subject.reify[:nested].should == { foo: 'bar', baz: 'qux' }
        end

        it "handles arrays" do
          subject.reify[:array].should == ['first', 'second']
        end

      end

    end
  end
end
