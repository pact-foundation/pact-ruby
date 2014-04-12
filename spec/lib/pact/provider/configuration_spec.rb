require 'spec_helper'
require 'pact/provider/configuration'

module Pact::Provider::Configuration

  describe ConfigurationExtension do

    before do
      Pact.clear_configuration
    end

    describe "diff_formatter_class" do

      it "returns the Pact::Matchers::NestedJsonDiffDecorator by default" do
        expect(Pact.configuration.diff_formatter_class).to eq(Pact::Matchers::NestedJsonDiffDecorator)
      end

      context "when plus_and_minus formatter is configured" do
        it "returns the Pact::Matchers::PlusMinusDiffDecorator" do
          Pact.configuration.diff_format = :plus_and_minus
          expect(Pact.configuration.diff_formatter_class).to eq(Pact::Matchers::PlusMinusDiffDecorator)
        end
      end

    end

    it "allows configuration of colour_enabled" do
      Pact.configuration.color_enabled = false
      expect(Pact.configuration.color_enabled).to be_false
    end

    it "sets color_enabled to be true by default" do
      expect(Pact.configuration.color_enabled).to be_true
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
