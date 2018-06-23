require 'spec_helper'
require 'pact/provider/configuration/pact_verification_with_tags'

module Pact
  module Provider
    module Configuration
      describe PactVerification do

        describe 'create_verification' do
          let(:url) { 'http://some/uri' }
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

          context "with valid values" do
            subject do
              uri = url
              tags = [tag]
              PactVerificationWithTags.build(tags, options) do
                pact_uri uri, pact_repository_uri_options
              end
            end

            it "creates a Verification" do
              pact_uri = Pact::Provider::PactURI.new(url, pact_repository_uri_options)
              tags = [tag]
              expect(Pact::Provider::PactVerificationWithTags).to receive(:new).with(tags, pact_uri)
              subject
            end
          end
        end
      end
    end
  end
end