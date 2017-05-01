require 'pact/provider/verifications/publish'

module Pact
  module Provider
    module Verifications
      describe Publish do
        describe "call" do
          let(:publish_verification_url) { nil }
          let(:pact_json) { {_links: {'pb:publish-verification': {href: publish_verification_url}}}.to_json }
          let(:app_version_set) { false }
          let(:verification_json) { '{"foo": "bar"}' }
          let(:auto_publish_verifications) { false }
          let(:verification) do
            instance_double("Pact::Verifications::Verification",
              to_json: verification_json,
              provider_application_version_set?: app_version_set
            )
          end

          let(:provider_configuration) do
            double('provider config', auto_publish_verifications?: auto_publish_verifications)
          end

          before do
            allow($stdout).to receive(:puts)
            allow(Pact.configuration).to receive(:provider).and_return(provider_configuration)
            stub_request(:post, 'http://broker/verifications')
          end

          subject { Publish.call(pact_json, verification)}

          context "when auto_publish_verifications is false" do
            it "does not publish the verification" do
              subject
              expect(WebMock).to_not have_requested(:post, 'http://broker/verifications')
            end
          end

          context "when auto_publish_verifications is true" do
            let(:auto_publish_verifications) { true }

            context "when the publish-verification link is not present" do
              it "does not publish the verification" do
                subject
                expect(WebMock).to_not have_requested(:post, 'http://broker/verifications')
              end
            end

            context "when the publish-verification link is present" do
              let(:publish_verification_url) { 'http://broker/verifications' }

              context "when the provider application version is not set" do
                it "raises an error" do
                  expect { subject }.to raise_error(Pact::Provider::Verifications::PublicationError, /Please set the provider application version/)
                end
              end

              context "when the provider application version is set" do
                let(:app_version_set) { true }

                it "publishes the verification" do
                  subject
                  expect(WebMock).to have_requested(:post, publish_verification_url).with(body: verification_json, headers: {'Content-Type' => 'application/json'})
                end

                context "when an HTTP error is returned" do
                  it "raises a PublicationError" do
                    stub_request(:post, 'http://broker/verifications').to_return(status: 500, body: 'some error')
                    expect{ subject }.to raise_error(PublicationError, /Error returned/)
                  end
                end

                context "when the connection can't be made" do
                  it "raises a PublicationError error" do
                    allow(Net::HTTP).to receive(:start).and_raise(SocketError)
                    expect{ subject }.to raise_error(PublicationError, /Failed to publish verification/)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
