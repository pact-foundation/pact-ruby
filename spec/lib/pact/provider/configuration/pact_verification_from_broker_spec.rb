require 'pact/provider/configuration/pact_verification'

module Pact
  module Provider
    module Configuration
      describe PactVerificationFromBroker do
        describe 'build' do
          let(:provider_name) {'provider-name'}
          let(:base_url) { "http://broker.org" }
          let(:basic_auth_options) do
            {
              username: 'pact_broker_username',
              password: 'pact_broker_password'
            }
          end
          let(:tags) { ['master'] }

          before do
            allow(Pact::PactBroker::FetchPacts).to receive(:new).and_return(fetch_pacts)
            allow(Pact.provider_world).to receive(:add_pact_uri_source)
          end

          context "with valid values" do
            subject do
              PactVerificationFromBroker.build(provider_name) do
                pact_broker_base_url base_url, basic_auth_options
                consumer_version_tags tags
              end
            end

            let(:fetch_pacts) { double('FetchPacts') }

            it "creates a instance of Pact::PactBroker::FetchPacts" do
              expect(Pact::PactBroker::FetchPacts).to receive(:new).with(provider_name, tags, base_url, basic_auth_options)
              subject
            end

            it "adds a pact_uri_source to the provider world" do
              expect(Pact.provider_world).to receive(:add_pact_uri_source).with(fetch_pacts)
              subject
            end
          end

          context "with a missing base url" do
            subject do
              PactVerificationFromBroker.build(provider_name) do

              end
            end

            let(:fetch_pacts) { double('FetchPacts') }

            it "raises an error" do
              expect { subject }.to raise_error Pact::Error, /Please provide a pact_broker_base_url/
            end
          end

          context "with a non array object for consumer_version_tags" do
            subject do
              PactVerificationFromBroker.build(provider_name) do
                pact_broker_base_url base_url
                consumer_version_tags "master"
              end
            end

            let(:fetch_pacts) { double('FetchPacts') }

            it "coerces the value into an array" do
              expect(Pact::PactBroker::FetchPacts).to receive(:new).with(anything, ["master"], anything, anything)
              subject
            end
          end

          context "when no consumer_version_tags are provided" do
            subject do
              PactVerificationFromBroker.build(provider_name) do
                pact_broker_base_url base_url
              end
            end

            let(:fetch_pacts) { double('FetchPacts') }

            it "creates an instance of FetchPacts with an emtpy array for the consumer_version_tags" do
              expect(Pact::PactBroker::FetchPacts).to receive(:new).with(anything, [], anything, anything)
              subject
            end
          end
        end
      end
    end
  end
end
