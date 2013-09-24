require 'spec_helper'
require 'pact/shared/dsl'

module Pact
  describe DSL do

    class TestDSL
      extend DSL
      attr_accessor :thing, :blah, :finally

      dsl do
        def with_thing thing
          self.thing = thing
        end
        def with_blah blah
          self.blah = blah
        end
      end

      def finalize
        @finally = 'yay'
      end
    end

    describe "build" do
       it "should support calling other variables and methods in scope" do
          def my_method
             'LA LA LA'
          end

          my_local_var = 123

          test = TestDSL.build do
            with_thing my_method
            with_blah my_local_var
          end

          expect(test.thing).to eq my_method
          expect(test.blah).to eq my_local_var
          expect(test.finally).to eq 'yay'
       end
    end
  end
end
