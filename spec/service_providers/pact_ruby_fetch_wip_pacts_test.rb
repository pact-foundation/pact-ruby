require_relative 'helper'
require 'pact/pact_broker/fetch_wip_pacts'

describe Pact::PactBroker::FetchWipPacts, pact: true do
  before do
    allow($stdout).to receive(:puts)
  end

  let(:get_headers) { { Accept: 'application/hal+json' } }

  describe 'fetch pacts' do
    let(:provider) { 'provider-1' }
    let(:broker_base_url) { pact_broker.mock_service_base_url + '/' }
    let(:basic_auth_options) { { username: 'foo', password: 'bar' } }

    before do
      pact_broker
        .given('the relations for retrieving WIP pacts exist in the index resource')
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
              'pb:wip-provider-pacts' => {
                href: Pact.term(
                  generate: broker_base_url + 'pacts/provider/{provider}/wip',
                  matcher: %r{/pacts/provider/{provider}/wip$}
                )
              }
            }
          }
        )
    end

    context 'retrieving WIP pacts by provider' do
      before do
        pact_broker
          .given('consumer-1 has a WIP pact with provider provider-1')
          .upon_receiving('a request to retrieve the WIP pacts for provider')
          .with(
            method: :get,
            path: '/pacts/provider/provider-1/wip',
            headers: get_headers
          )
          .will_respond_with(
            status: 200,
            body: {
              _links: {
                'pb:pacts' => [
                  {
                    href: Pact.term('http://pact-broker-url-for-consumer-1', %r{http://.*})
                  }
                ]
              }
            }
          )
      end

      it 'returns the array of pact urls' do
        pacts = Pact::PactBroker::FetchWipPacts.call(provider, broker_base_url, basic_auth_options)
        expect(pacts).to eq(
          [
            Pact::Provider::PactURI.new('http://pact-broker-url-for-consumer-1', basic_auth_options)
          ]
        )
      end
    end
  end
end
