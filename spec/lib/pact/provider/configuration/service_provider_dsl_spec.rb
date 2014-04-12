require 'spec_helper'
require 'pact/provider/configuration/service_provider_dsl'

module Pact

  module Provider

    module Configuration

      describe ServiceProviderDSL do

        describe "initialize" do

          context "with an object instead of a block" do
            subject do
              ServiceProviderDSL.build 'name' do
                app 'blah'
              end
            end
            it "raises an error" do
              expect{ subject }.to raise_error /wrong number of arguments/
            end
          end

        end

        describe "validate" do
          context "when no name is provided" do
            subject do
              ServiceProviderDSL.new ' ' do
                app { Object.new }
              end
            end
            it "raises an error" do
              expect{ subject.send(:validate)}.to raise_error("Please provide a name for the Provider")
            end
          end
          context "when nil name is provided" do
            subject do
              ServiceProviderDSL.new nil do
                app { Object.new }
              end
            end
            it "raises an error" do
              expect{ subject.send(:validate)}.to raise_error("Please provide a name for the Provider")
            end
          end
        end

        describe 'honours_pact_with' do
          before do
            Pact.clear_configuration
          end

          context "with no optional params" do
            subject do
              ServiceProviderDSL.build 'some-provider' do
                app {}
                honours_pact_with 'some-consumer' do
                  pact_uri 'blah'
                end
              end
            end
            it 'adds a verification to the Pact.configuration' do
              subject
              expect(Pact.configuration.pact_verifications.first).to eq(Pact::Provider::PactVerification.new('some-consumer', 'blah', :head))
            end
          end

          context "with all params specified" do
            subject do
              ServiceProviderDSL.build 'some-provider' do
                app {}
                honours_pact_with 'some-consumer', :ref => :prod do
                  pact_uri 'blah'
                end
              end
            end
            it 'adds a verification to the Pact.configuration' do
              subject
              expect(Pact.configuration.pact_verifications.first).to eq(Pact::Provider::PactVerification.new('some-consumer', 'blah', :prod))
            end

          end

        end
      end

    end
  end
end

