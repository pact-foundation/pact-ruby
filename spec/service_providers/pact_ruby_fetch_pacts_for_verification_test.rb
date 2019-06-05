require_relative 'helper'
require 'pact/pact_broker/fetch_pacts_for_verification'

describe Pact::PactBroker::FetchPactsForVerification, pact: true do
  before do
    allow($stdout).to receive(:puts)
  end

  let(:get_headers) { { Accept: 'application/hal+json' } }
  let(:pacts_for_verification_relation) { Pact::PactBroker::FetchPactsForVerification::PACTS_FOR_VERIFICATION_RELATION }
  let(:query) { { "provider_version_tags" => %[dev] } }

  subject { Pact::PactBroker::FetchPactsForVerification.call(provider, query,broker_base_url, basic_auth_options) }

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
          .given('Foo has a pact with provider Bar')
          .upon_receiving('a request to retrieve the pacts for verification for a provider')
          .with(
            method: :get,
            path: '/pacts/provider/Bar/for-verification',
            query: query,
            headers: get_headers
          )
          .will_respond_with(
            status: 200,
            body: {
              "_embedded" => {
                "pacts" => [{
                  "verificationProperties" => {
                    "pending" => Pact.like(true),
                    "pendingReason" => Pact.like("pending reason"),
                    "inclusionReason" => Pact.like("inclusion reason")
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
          inclusion_reason: "inclusion reason",
          pending_reason: "pending reason"
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
