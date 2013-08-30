require 'spec_helper'
require 'pact/provider/dsl'

module Pact::Provider
  describe DSL do

    class MockConfig
      include Pact::Provider::DSL
    end

    describe "service_provider" do
      before do
        Pact.clear_configuration
      end
      let(:mock_config) { MockConfig.new }
      context "when a provider is configured" do
        before do
          mock_config.service_provider "Fred" do
            app { "An app" }
          end
        end
        it "should allow configuration of the name" do
          expect(Pact.configuration.provider.name).to eql "Fred"
        end
        it "should allow configuration of the test app" do
          expect(Pact.configuration.provider.app).to eql "An app"
        end
      end
      #Move this test to configuration
      context "when a provider is not configured" do
        it "raises an error" do
          expect{ Pact.configuration.provider }.to raise_error(/Please configure your provider/)
        end
      end
    end


    module DSL

    #   describe ProviderDSL do

    #     describe "initialize" do

    #       context "with an object instead of a block" do
    #         subject do
    #           ProviderDSL.new do
    #             name nil
    #             app 'blah'
    #           end
    #         end
    #         it "raises an error" do
    #           expect{ subject }.to raise_error
    #         end
    #       end


    #     end
    #     describe "validate" do
    #       context "when no name is provided" do
    #         subject do
    #           ProviderDSL.new do
    #             app { Object.new }
    #           end
    #         end
    #         it "raises an error" do
    #           expect{ subject.validate}.to raise_error("Please provide a name for the Provider")
    #         end
    #       end
    #       context "when nil name is provided" do
    #         subject do
    #           ProviderDSL.new do
    #             name nil
    #             app { Object.new }
    #           end
    #         end
    #         it "raises an error" do
    #           expect{ subject.validate}.to raise_error("Please provide a name for the Provider")
    #         end
    #       end
    #       context "when no app is provided" do
    #         subject do
    #           ProviderDSL.new do
    #             name 'Blah'
    #           end
    #         end
    #         it "raises an error" do
    #           expect{ subject.validate }.to raise_error("Please configure an app for the Provider")
    #         end
    #       end
    #     end
    #   end

      # describe ProviderConfig do
      #   describe "app" do
      #     subject { ProviderConfig.new("blah") { Object.new } }
      #     it "should execute the app_block each time" do
      #       expect(subject.app.object_id).to_not equal(subject.app.object_id)
      #     end
      #   end
      # end

    end
  end
end
