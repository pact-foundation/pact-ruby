require 'pact/provider/verification_results/publish'

module Pact
  module Provider
    module VerificationResults
      describe Publish do
        describe "call" do
          let(:publish_verification_url) { nil }
          let(:stubbed_publish_verification_url) { 'http://broker/something/provider/Bar/verifications' }
          let(:tag_version_url) { 'http://tag-me/{tag}' }
          let(:pact_source) { instance_double("Pact::Provider::PactSource", pact_hash: pact_hash, uri: pact_url)}
          let(:pact_url) { instance_double("Pact::Provider::PactURI", basic_auth?: basic_auth, username: 'username', password: 'password')}
          let(:provider_url) { 'http://provider' }
          let(:basic_auth) { false }
          let(:pact_hash) do
            {
              'consumer' => {
                'name' => 'Foo'
              },
              '_links' => {
                'pb:publish-verification-results'=> {
                  'href' => publish_verification_url
                },
                'pb:provider' => {
                  'href' => provider_url
                }
              }
            }
          end
          let(:created_verification_body) do
            {
              '_links' => {
                'self' => {
                  'href' => 'http://broker/new-verification'
                }
              }
            }.to_json
          end
          let(:provider_body) do
            {
              '_links' => {
                'self' => {
                  'href' => provider_url
                },
                'pb:version-tag' => {
                  'href' => 'http://provider/version/{version}/tag/{tag}'
                }
              }
            }.to_json
          end
          let(:tag_body) do
            {
              '_links' => {
                'self' => {
                  'href' => 'http://tag-url'
                }
              }
            }.to_json
          end
          let(:app_version_set) { false }
          let(:verification_json) { '{"foo": "bar"}' }
          let(:publish_verification_results) { false }
          let(:publishable) { true }
          let(:tags) { [] }
          let(:verification) do
            instance_double("Pact::Verifications::Verification",
              to_json: verification_json,
              provider_application_version_set?: app_version_set,
              publishable?: publishable
            )
          end

          let(:provider_configuration) do
            double('provider config', publish_verification_results?: publish_verification_results, tags: tags, application_version: '1.2.3')
          end

          before do
            allow($stdout).to receive(:puts)
            allow($stderr).to receive(:puts)
            allow(Pact.configuration).to receive(:provider).and_return(provider_configuration)
            stub_request(:post, stubbed_publish_verification_url).to_return(status: 200, body: created_verification_body)
            stub_request(:put, 'http://provider/version/1.2.3/tag/foo').to_return(status: 200, headers: { 'Content-Type' => 'application/hal+json'}, body: tag_body)
            stub_request(:get, provider_url).to_return(status: 200, headers: { 'Content-Type' => 'application/hal+json'}, body: provider_body)
            allow(Retry).to receive(:until_true) { |&block| block.call }
          end

          subject { Publish.call(pact_source, verification) }

          context "when publish_verification_results is false" do
            it "does not publish the verification" do
              subject
              expect(WebMock).to_not have_requested(:post, 'http://broker/something/provider/Bar/verifications')
            end
          end

          context "when publish_verification_results is true" do
            let(:publish_verification_results) { true }

            context "when the publish-verification link is present" do
              let(:publish_verification_url) { stubbed_publish_verification_url }

              it "publishes the verification" do
                subject
                expect(WebMock).to have_requested(:post, publish_verification_url).with(body: verification_json, headers: {'Content-Type' => 'application/json', 'Accept' => 'application/hal+json, */*'} )
              end

              context "when the verification result is not publishable" do
                let(:publishable) { false }

                it "does not publish the verification" do
                  subject
                  expect(WebMock).to_not have_requested(:post, stubbed_publish_verification_url)
                end
              end

              context "with tags" do
                let(:tags) { ['foo'] }

                it "tags the provider version" do
                  subject
                  expect(WebMock).to have_requested(:put, 'http://provider/version/1.2.3/tag/foo').with(headers: {'Content-Type' => 'application/json'})
                end

                context "when there is no pb:publish-verification-results link" do
                  before do
                    pact_hash['_links'].delete('pb:publish-verification-results')
                  end

                  it "does not tag the version" do
                    subject
                    expect(WebMock).to_not have_requested(:put, /.*/)
                  end
                end
              end

              context "when there are no tags specified and there is no pb:tag-version link" do
                before do
                  pact_hash['_links'].delete('pb:tag-version')
                end
                let(:tags) { [] }

                it "does not print a warning" do
                  expect($stderr).to_not receive(:puts).with /WARN: Cannot tag provider version/
                  subject
                end
              end

              context "when basic auth is configured on the pact URL" do
                let(:basic_auth) { true }
                it "sets the username and password for the pubication URL" do
                  subject
                  expect(WebMock).to have_requested(:post, publish_verification_url).with(basic_auth: ['username', 'password'])
                end
              end

              context "when an HTTP error is returned" do
                it "raises a PublicationError" do
                  stub_request(:post, stubbed_publish_verification_url).to_return(status: 500, body: '{}')
                  expect{ subject }.to raise_error(PublicationError, /Error returned/)
                end
              end

              context "when the connection can't be made" do
                it "raises a PublicationError error" do
                  allow(Net::HTTP).to receive(:start).and_raise(SocketError)
                  expect{ subject }.to raise_error(PublicationError, /Failed to publish verification/)
                end
              end

              context "with https" do
                before do
                  stub_request(:post, publish_verification_url).to_return(status: 200, body: created_verification_body)
                end
                let(:publish_verification_url) { stubbed_publish_verification_url.gsub('http', 'https') }

                it "uses ssl" do
                  subject
                  expect(WebMock).to have_requested(:post, publish_verification_url)
                end
              end
            end
          end
        end
      end
    end
  end
end
