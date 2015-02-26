require 'spec_helper'
require 'pact/provider/configuration/service_provider_dsl'
require 'pact/provider/pact_repository_uri'

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
            Pact.clear_provider_world
          end
          let(:pact_url) { 'blah'}

          context "with no optional params" do
            subject do
              ServiceProviderDSL.build 'some-provider' do
                app {}
                honours_pact_with 'some-consumer' do
                  pact_uri pact_url
                end
              end
            end
            it 'adds a verification to the Pact.provider_world' do
              subject
              pact_repository_uri = Pact::Provider::PactRepositoryUri.new(pact_url)
              expect(Pact.provider_world.pact_verifications.first).to eq(Pact::Provider::PactVerification.new('some-consumer', pact_repository_uri, :head))
            end
          end

          context "with all params specified" do
            let(:pact_uri_options) do
              {
                username: 'pact_user',
                password: 'pact_pw'
              }
            end
            subject do
              ServiceProviderDSL.build 'some-provider' do
                app {}
                honours_pact_with 'some-consumer', :ref => :prod do
                  pact_uri pact_url, pact_uri_options
                end
              end
            end
            it 'adds a verification to the Pact.provider_world' do
              subject
              pact_repository_uri = Pact::Provider::PactRepositoryUri.new(pact_url, pact_uri_options)
              expect(Pact.provider_world.pact_verifications.first).to eq(Pact::Provider::PactVerification.new('some-consumer', pact_repository_uri , :prod))
            end

          end

        end

        describe "CONFIG_RU_APP" do
          context "when a config.ru file does not exist" do

            let(:path_that_does_not_exist) { './tmp/this/path/does/not/exist/probably' }

            before do
              allow(Pact.configuration).to receive(:config_ru_path).and_return(path_that_does_not_exist)
            end

            it "raises an error with some helpful text" do
              expect{ ServiceProviderDSL::CONFIG_RU_APP.call }.to raise_error /Could not find config\.ru file.*#{Regexp.escape(path_that_does_not_exist)}/
            end

          end
        end
      end

    end
  end
end

