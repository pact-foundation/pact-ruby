require 'spec_helper'
require 'pact/provider/rspec'

describe "provider side" do
   describe "configure" do

      class TestHelper
         include Pact::Provider::RSpec::InstanceMethods
      end

      let(:application) { double("App")}

      before do
         app_block = ->{ application }
         Pact.service_provider "My Provider" do
            app &app_block
         end
      end

      it "makes the app available to the tests" do
         expect(TestHelper.new.app).to be(application)
      end

   end
end