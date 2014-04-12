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

        describe "#diff_formatter" do

          it "returns the Pact::Matchers::NestedJsonDiffFormatter by default" do
            expect(subject.diff_formatter).to eq(Pact::Matchers::NestedJsonDiffFormatter)
          end

          ConfigurationExtension::DIFF_FORMATTERS.each_pair do | key, diff_formatter |

            context "when set to :#{key}" do

              before do
                subject.diff_formatter = key
              end

              it "sets the diff_formatter to #{diff_formatter}" do
                expect(subject.diff_formatter).to be diff_formatter
              end
            end

          end

          context "when set to an object that responds to call" do

            let(:diff_formatter) { lambda{ | diff| } }

            before do
              subject.diff_formatter = diff_formatter
            end

            it "sets the diff_formatter to the object" do
              expect(subject.diff_formatter).to be diff_formatter
            end
          end

          context "when set to an object that does not respond to call and isn't a known default option" do
            it "raises an error" do
              expect { subject.diff_formatter = Object.new }.to raise_error "Pact.configuration.diff_formatter needs to respond to call, or be in the preconfigured list: [:nested_json, :plus_and_minus, :list_of_paths]"
            end
          end

        end
      end
    end
  end
end