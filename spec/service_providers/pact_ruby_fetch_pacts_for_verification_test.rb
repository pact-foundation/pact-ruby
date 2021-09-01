require_relative 'helper'
require 'pact/pact_broker/fetch_pact_uris_for_verification'

describe Pact::PactBroker::FetchPactURIsForVerification, pact: true do
  before do
    allow($stdout).to receive(:puts)
  end

  let(:get_headers) { { "Accept" => 'application/hal+json' } }
  let(:post_headers) do
    {
      "Accept" => 'application/hal+json',
      "Content-Type" => "application/json"
    }
  end
  let(:pacts_for_verification_relation) { Pact::PactBroker::FetchPactURIsForVerification::PACTS_FOR_VERIFICATION_RELATION }
  let(:body) do
    {
      "providerVersionBranch" => "main",
      "providerVersionTags"  => ["pdev"],
      "consumerVersionSelectors" => [{ "tag" => "cdev", "latest" => true}],
      "includePendingStatus" => true
    }
  end
  let(:provider_version_branch) { "main" }
  let(:provider_version_tags) { %w[pdev] }
  let(:consumer_version_selectors) { [ { tag: "cdev", latest: true }] }
  let(:options) { { include_pending_status: true }}

  subject { Pact::PactBroker::FetchPactURIsForVerification.call(provider, consumer_version_selectors, provider_version_branch, provider_version_tags, broker_base_url, basic_auth_options, options) }

  describe 'fetch pacts' do
    let(:provider) { 'Bar' }
    let(:broker_base_url) { pact_broker.mock_service_base_url}
    let(:basic_auth_options) { { username: 'username', password: 'password' } }

    before do
      pact_broker
        .given('the relation for retrieving pacts for verifications exists in the index resource')
        .upon_receiving('a request for the index resource')
        .with(
          method: :get,
          path: '/',
          headers: get_headers
        )
        .will_respond_with(
          status: 200,
          headers: { "Content-Type" => Pact.term("application/hal+json", /hal/) },
          body: {
            _links: {
               pacts_for_verification_relation => {
                href: Pact.term(
                  generate: broker_base_url + '/pacts/provider/{provider}/for-verification',
                  matcher: %r{/pacts/provider/{provider}/for-verification$}
                )
              }
            }
          }
        )
    end

    context 'retrieving pacts for verification by provider' do
      before do
        pact_broker
          .given('Foo has a pact tagged cdev with provider Bar')
          .upon_receiving('a request to retrieve the pacts for verification for a provider')
          .with(
            method: :post,
            path: '/pacts/provider/Bar/for-verification',
            body: body,
            headers: post_headers
          )
          .will_respond_with(
            status: 200,
            headers: { "Content-Type" => Pact.term("application/hal+json", /hal/) },
            body: {
              "_embedded" => {
                "pacts" => [{
                  "shortDescription" => "a description",
                  "verificationProperties" => {
                    "pending" => Pact.like(true),
                    "notices" => Pact.each_like("text" => "some text")
                  },
                  '_links' => {
                    "self" => {
                      "href" => Pact.term('http://pact-broker-url-for-foo', %r{http://.*})
                    }
                  }
                }]
              }
            }
          )
      end

      let(:expected_metadata) do
        {
          pending: true,
          notices: [
            text: "some text"
          ],
          short_description: "a description"
         }
      end

      it 'returns the array of pact urls' do
        expect(subject).to eq(
          [
            Pact::Provider::PactURI.new('http://pact-broker-url-for-foo', basic_auth_options, expected_metadata)
          ]
        )
      end
    end
  end
end
