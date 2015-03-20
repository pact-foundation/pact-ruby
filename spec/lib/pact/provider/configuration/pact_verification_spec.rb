require 'spec_helper'
require 'pact/provider/configuration/pact_verification'

module Pact
  module Provider
    module Configuration
      describe PactVerification do

        describe 'create_verification' do
          let(:url) {'http://some/uri'}
          let(:pact_repository_uri_options) do
            {
              username: 'pact_broker_username',
              password: 'pact_broker_password'
            }
          end
          let(:consumer_name) {'some consumer'}
          let(:ref) {:prod}
          let(:options) { {:ref => :prod} }
          context "with valid values" do
            subject do
              uri = url
              PactVerification.build(consumer_name, options) do
                pact_uri uri, pact_repository_uri_options
              end
            end

            it "creates a Verification" do
              pact_repository_uri = Pact::Provider::PactRepositoryUri.new(url, pact_repository_uri_options)
              expect(Pact::Provider::PactVerification).to receive(:new).with(consumer_name, pact_repository_uri, ref)
              subject
            end
          end

          context "with a nil uri" do
            subject do
              PactVerification.build(consumer_name, options) do
                pact_uri nil
              end
            end

            it "raises a validation error" do
              expect{ subject }.to raise_error /Please provide a pact_uri/
            end
          end
        end
      end
    end
  end
end