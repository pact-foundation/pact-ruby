require 'spec_helper'
require 'pact/provider/configuration/configuration_extension'

module Pact

  module Provider

    module Configuration

      describe ConfigurationExtension do

        subject { Object.new.extend(ConfigurationExtension) }

        describe "#color_enabled" do

          it "sets color_enabled to be true by default" do
            expect(subject.color_enabled).to be_true
          end

          it "allows configuration of colour_enabled" do
            subject.color_enabled = false
            expect(subject.color_enabled).to be_false
          end

        end

      end
    end
  end
end