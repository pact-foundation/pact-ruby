require 'pact/provider/configuration/pact_verification'

module Pact
  module Provider
    module Configuration
      describe PactVerificationFromBroker do
        describe 'build' do
          let(:provider_name) {'provider-name'}
          let(:provider_version_branch) { 'main' }
          let(:provider_version_tags) { ['master'] }
          let(:base_url) { "http://broker.org" }
          let(:since) { "2020-01-01" }
          let(:basic_auth_options) do
            {
              username: 'pact_broker_username',
              password: 'pact_broker_password'
            }
          end
          let(:tags) { ['master'] }
          let(:fetch_pacts) { double('FetchPacts') }

          before do
            allow(Pact::PactBroker::FetchPactURIsForVerification).to receive(:new).and_return(fetch_pacts)
            allow(Pact.provider_world).to receive(:add_pact_uri_source)
          end

          context "with valid values" do
            subject do
              PactVerificationFromBroker.build(provider_name, provider_version_branch, provider_version_tags) do
                pact_broker_base_url base_url, basic_auth_options
                consumer_version_tags tags
                enable_pending true
                include_wip_pacts_since since
                verbose true
              end
            end

            let(:fetch_pacts) { double('FetchPacts') }
            let(:basic_auth_opts) { basic_auth_options.merge(verbose: true) }
            let(:options) { { fail_if_no_pacts_found: true, include_pending_status: true, include_wip_pacts_since: "2020-01-01" }}
            let(:consumer_version_selectors) { [ { tag: 'master', latest: true }] }

            it "creates a instance of Pact::PactBroker::FetchPactURIsForVerification" do
              expect(Pact::PactBroker::FetchPactURIsForVerification).to receive(:new).with(
                provider_name,
                consumer_version_selectors,
                provider_version_branch,
                provider_version_tags,
                base_url,
                basic_auth_opts,
                options
              )
              subject
            end

            it "adds a pact_uri_source to the provider world" do
              expect(Pact.provider_world).to receive(:add_pact_uri_source).with(fetch_pacts)
              subject
            end

            context "when since is a Date" do
              let(:since) { Date.new(2020, 1, 1) }

              it "converts it to a string" do
                expect(Pact::PactBroker::FetchPactURIsForVerification).to receive(:new).with(
                  anything,
                  anything,
                  anything,
                  anything,
                  anything,
                  anything,
                  {
                    fail_if_no_pacts_found: true,
                    include_pending_status: true,
                    include_wip_pacts_since: since.xmlschema
                  }
                )
                subject
              end
            end
          end

          context "with a missing base url" do
            subject do
              PactVerificationFromBroker.build(provider_name, provider_version_branch, provider_version_tags) do

              end
            end

            it "raises an error" do
              expect { subject }.to raise_error Pact::Error, /Please provide a pact_broker_base_url/
            end
          end

          context "with a non array object for consumer_version_tags" do
            subject do
              PactVerificationFromBroker.build(provider_name, provider_version_branch, provider_version_tags) do
                pact_broker_base_url base_url
                consumer_version_tags "master"
              end
            end

            it "coerces the value into an array" do
              expect(Pact::PactBroker::FetchPactURIsForVerification).to receive(:new).with(anything, [{ tag: "master", latest: true}], anything, anything, anything, anything, anything)
              subject
            end
          end

          context "when no consumer_version_tags are provided" do
            subject do
              PactVerificationFromBroker.build(provider_name, provider_version_branch, provider_version_tags) do
                pact_broker_base_url base_url
              end
            end

            it "creates an instance of FetchPacts with an empty array for the consumer_version_tags" do
              expect(Pact::PactBroker::FetchPactURIsForVerification).to receive(:new).with(anything, [], anything, anything, anything, anything, anything)
              subject
            end
          end

          context "when the old format of selector is supplied to the consumer_verison_tags" do
            let(:tags) { [{ name: 'main', all: true, fallback: 'fallback' }] }

            subject do
              PactVerificationFromBroker.build(provider_name, provider_version_branch, provider_version_tags) do
                pact_broker_base_url base_url
                consumer_version_tags tags
              end
            end

            it "converts them to selectors" do
              expect(Pact::PactBroker::FetchPactURIsForVerification).to receive(:new).with(anything, [{ tag: "main", latest: false, fallbackTag: 'fallback'}], anything, anything, anything, anything, anything)
              subject
            end
          end

          context "when an invalid class is used for the consumer_version_tags" do
            let(:tags) { [true] }

            subject do
              PactVerificationFromBroker.build(provider_name, provider_version_branch, provider_version_tags) do
                pact_broker_base_url base_url
                consumer_version_tags tags
              end
            end

            it "raises an error" do
              expect { subject }.to raise_error Pact::Error, "The value supplied for consumer_version_tags must be a String or a Hash. Found TrueClass"
            end
          end

          context "when consumer_version_selectors are provided" do
            let(:tags) { [{ tag: 'main', latest: true, fallback_tag: 'fallback' }] }

            subject do
              PactVerificationFromBroker.build(provider_name, provider_version_branch, provider_version_tags) do
                pact_broker_base_url base_url
                consumer_version_selectors tags
              end
            end

            it "converts the casing of the key names" do
              expect(Pact::PactBroker::FetchPactURIsForVerification).to receive(:new).with(anything, [{ tag: "main", latest: true, fallbackTag: 'fallback'}], anything, anything, anything, anything, anything)
              subject
            end
          end

          context "when no verbose flag is provided" do
            subject do
              PactVerificationFromBroker.build(provider_name, provider_version_branch, provider_version_tags) do
                pact_broker_base_url base_url
              end
            end

            it "creates an instance of FetchPactURIsForVerification with verbose: false" do
              expect(Pact::PactBroker::FetchPactURIsForVerification).to receive(:new).with(anything, anything, anything, anything, anything, hash_including(verbose: false), anything)
              subject
            end
          end
        end
      end
    end
  end
end
