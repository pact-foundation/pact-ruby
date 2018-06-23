require 'spec_helper'
require 'pact/provider/configuration/pact_verification_with_tags'
require 'pact/pact_broker/fetch_pacts'

module Pact
  module Provider
    module Configuration
      describe PactVerification do

        describe 'create_verification' do
          let(:url) { 'http://some/uri' }
          let(:provider_name) {'provider-name'}
          let(:pact_repository_uri_options) do
            {
              username: 'pact_broker_username',
              password: 'pact_broker_password'
            }
          end
          let(:tag) do
            {
              name: 'tag-name',
              all: false,
              fallback: 'master'
            }
          end

          let(:options) do
            {
              pact_broker_base_url: url,
              consumer_version_tags: [tag]
            }
          end
          context "with valid values" do
            subject do
              PactVerificationWithTags.build(provider_name, options) do
              end
            end

            it "creates a Verification" do
              allow(Pact::PactBroker::FetchPacts).to receive(:call).and_return(['pact-urls'])

              tags = [tag]
              expect(Pact::PactBroker::FetchPacts).to receive(:call).with(provider_name, tags, url, options)
              expect(Pact::Provider::PactVerificationWithTags).to receive(:new).with('pact-urls')
              subject
            end
          end
        end
      end
    end
  end
end