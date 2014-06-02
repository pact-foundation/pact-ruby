require 'spec_helper'
require 'pact/shared/dsl'
require 'support/dsl_spec_support'

module Pact
  describe DSL do

    class TestDSL
      extend DSL
      attr_accessor :thing, :blah, :global, :the_block, :another_block, :finalized

      dsl do
        def with_thing thing
          self.thing = thing
        end
        def with_blah blah
          self.blah = blah
        end
        def with_global global
          self.global = global
        end

        def with_block &the_block
          self.the_block = the_block
        end

        def with_another_block &the_block
          self.another_block = the_block
        end

      end

      def finalize
        @finalized = true
      end
    end

    describe "build" do
       before do
          def my_local_method
             'LA LA LA'
          end

          my_local_var = 123

          local_app = "I'm a local app"

          @test = TestDSL.build do
            with_thing my_local_method
            with_blah my_local_var
            with_global global_method
            with_block do
              global_app
            end
            with_another_block do
              local_app
            end
          end
       end

       it "supports using a local variable" do
          expect(@test.blah).to eq 123
       end

       it "supports using a local method" do
          expect(@test.thing).to eq 'LA LA LA'
       end

       it "supports using global methods from other files" do
         expect(@test.global).to eq "I'm global"
       end

       it "supports using a local method to provide the app" do
         expect(@test.another_block.call).to eq("I'm a local app")
       end

       it "should support using a global method to provide the app but it doesn't" do
         expect(@test.the_block.call).to eq("I'm a global app")
       end

       it "calls finalize" do
        expect(@test.finalized).to be true
       end
    end
  end
end
