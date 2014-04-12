require 'spec_helper'
require 'pact/provider/configuration'

module Pact::Provider::Configuration

  describe ConfigurationExtension do

    before do
      Pact.clear_configuration
    end

    describe "service_provider" do

      context "when a provider is configured" do

        before do
          Pact.service_provider "Fred" do
            app { "An app" }
          end
        end

        it "should allow configuration of the test app" do
          expect(Pact.configuration.provider.app).to eql "An app"
        end

      end

      context "when a provider is not configured" do

        it "raises an error" do
          expect{ Pact.configuration.provider }.to raise_error(/Please configure your provider/)
        end

      end

      context "when a provider is configured without an app" do

        before do
          Pact.service_provider "Fred" do
          end
        end

        it "uses the app from config.ru" do
          expect( Pact.configuration.provider.app ).to be(AppForConfigRu)
        end

      end
    end
  end
end
