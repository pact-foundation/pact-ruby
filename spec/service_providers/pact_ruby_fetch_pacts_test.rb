require 'pact/consumer/rspec'
require 'pact/pact_broker/fetch_pacts'

Pact.service_consumer 'Pact Ruby' do
  has_pact_with 'Pact Broker' do
    mock_service :pact_broker do
      port 1234
      pact_specification_version '2.0.0'
    end
  end
end

describe Pact::PactBroker::FetchPacts, pact: true do

  let(:get_headers) { {Accept: 'application/hal+json'} }

  describe 'fetch pacts' do
    let(:provider) { 'provider-1' }
    let(:broker_base_url) { pact_broker.mock_service_base_url + '/' }
    let(:basic_auth_options) { {username: 'foo', password: 'bar'} }

    before do
      pact_broker
        .given('the relations for retrieving pacts exist in the index resource')
        .upon_receiving('a request for the index resource')
        .with(
          method: :get,
          path: '/',
          headers: get_headers
        ).
        will_respond_with(
          status: 200,
          body: {
            _links: {
              'pb:latest-provider-pacts' => {
                href: Pact.term(
                  generate: broker_base_url + 'pacts/provider/{provider}/latest',
                  matcher: %r{/pacts/provider/{provider}/latest$}
                )
              },
              'pb:latest-provider-pacts-with-tag' => {
                href: Pact.term(
                  generate: broker_base_url + 'pacts/provider/{provider}/latest/{tag}',
                  matcher: %r{/pacts/provider/{provider}/latest/{tag}$}
                )

              },
              :'pb:provider-pacts-with-tag' => {
                href: Pact.term(
                  generate: broker_base_url + 'pacts/provider/{provider}/tag/{tag}',
                  matcher: %r{/pacts/provider/{provider}/tag/{tag}$}
                )

              },
              'pb:provider-pacts' => {
                href: Pact.term(
                  generate: broker_base_url + 'pacts/provider/{provider}',
                  matcher: %r{/pacts/provider/{provider}$}
                )
              }
            }
          }
        )
    end

    context 'retrieving latest pacts by provider' do
      let(:tags) { nil }
      let(:all_pacts) { false }

      before do
        pact_broker
          .given('consumer-1 and consumer-2 have pacts with provider provider-1')
          .upon_receiving('a request to retrieve the latest pacts for provider')
          .with(
            method: :get,
            path: '/pacts/provider/provider-1/latest',
            headers: get_headers
          ).
          will_respond_with(
            status: 200,
            body: {
              _links: {
                pacts: [
                  {
                    href: Pact.like('pact-broker-url-for-consumer-1')
                  },
                  {
                    href: Pact.like('pact-broker-url-for-consumer-2')
                  }
                ]
              }
            }
          )
      end

      it 'returns the array of pact urls' do
        pacts = Pact::PactBroker::FetchPacts.call(provider, tags, broker_base_url, basic_auth_options, all_pacts)

        expect(pacts).to eq(%w[pact-broker-url-for-consumer-1 pact-broker-url-for-consumer-2])
      end
    end

    context 'retrieving latest pacts by provider with the specified tag' do
      let(:tags) { %w[tag-1 tag-2] }
      let(:all_pacts) { false }

      before do
        pact_broker
          .given('consumer-1 and consumer-2 have pacts with provider provider-1 tagged with tag-1')
          .upon_receiving('a request to retrieve the latest tagged (tag-1) pacts for provider')
          .with(
            method: :get,
            path: '/pacts/provider/provider-1/latest/tag-1',
            headers: get_headers
          ).
          will_respond_with(
            status: 200,
            body: {
              _links: {
                pacts: [
                  {
                    href: Pact.like('pact-broker-url-for-consumer-1-tag-1')
                  },
                  {
                    href: Pact.like('pact-broker-url-for-consumer-2-tag-1')
                  }
                ]
              }
            }
          )
        pact_broker
          .given('consumer-1 and consumer-2 have pacts with provider provider-1 tagged with tag-2')
          .upon_receiving('a request to retrieve the latest tagged (tag-2) pacts for provider')
          .with(
            method: :get,
            path: '/pacts/provider/provider-1/latest/tag-2',
            headers: get_headers
          ).
          will_respond_with(
            status: 200,
            body: {
              _links: {
                pacts: [
                  {
                    href: Pact.like('pact-broker-url-for-consumer-1-tag-2')
                  },
                  {
                    href: Pact.like('pact-broker-url-for-consumer-2-tag-2')
                  }
                ]
              }
            }
          )
      end

      it 'returns the array of pact urls' do
        pacts = Pact::PactBroker::FetchPacts.call(provider, tags, broker_base_url, basic_auth_options, all_pacts)

        expect(pacts).to eq(%w[pact-broker-url-for-consumer-1-tag-1 pact-broker-url-for-consumer-2-tag-1
                               pact-broker-url-for-consumer-1-tag-2 pact-broker-url-for-consumer-2-tag-2])
      end
    end

    context 'retrieving all pact versions for the provider with the specified consumer version tag' do
      let(:tags) { %w[tag-1 tag-2] }
      let(:all_pacts) { true }

      before do
        pact_broker
          .given('consumer-1 and consumer-2 have 2 pacts with provider provider-1 tagged with tag-1')
          .upon_receiving('a request to retrieve all pact versions for the provider with the specified consumer version tag (tag-1)')
          .with(
            method: :get,
            path: '/pacts/provider/provider-1/tag/tag-1',
            headers: get_headers
          ).
          will_respond_with(
            status: 200,
            body: {
              _links: {
                pacts: [
                  {
                    href: Pact.like('pact-broker-url-for-consumer-1-tag-1-all')
                  },
                  {
                    href: Pact.like('pact-broker-url-for-consumer-2-tag-1-all')
                  }
                ]
              }
            }
          )
        pact_broker
          .given('consumer-1 and consumer-2 have 2 pacts with provider provider-1 tagged with tag-2')
          .upon_receiving('a request to retrieve all pact versions for the provider with the specified consumer version tag (tag-2)')
          .with(
            method: :get,
            path: '/pacts/provider/provider-1/tag/tag-2',
            headers: get_headers
          ).
          will_respond_with(
            status: 200,
            body: {
              _links: {
                pacts: [
                  {
                    href: Pact.like('pact-broker-url-for-consumer-1-tag-2-all')
                  },
                  {
                    href: Pact.like('pact-broker-url-for-consumer-2-tag-2-all')
                  }
                ]
              }
            }
          )
      end

      it 'returns the array of pact urls' do
        pacts = Pact::PactBroker::FetchPacts.call(provider, tags, broker_base_url, basic_auth_options, all_pacts)

        expect(pacts).to eq(%w[pact-broker-url-for-consumer-1-tag-1-all pact-broker-url-for-consumer-2-tag-1-all
            pact-broker-url-for-consumer-1-tag-2-all pact-broker-url-for-consumer-2-tag-2-all])
      end
    end

    context 'retrieving all pact versions for the specified provider' do
      let(:tags) { nil }
      let(:all_pacts) { true }

      before do
        pact_broker
          .given('consumer-1 and consumer-2 have 2 pacts with provider provider-1')
          .upon_receiving('a request to retrieve all pact versions for the specified provider')
          .with(
            method: :get,
            path: '/pacts/provider/provider-1',
            headers: get_headers
          ).
          will_respond_with(
            status: 200,
            body: {
              _links: {
                pacts: [
                  {
                    href: Pact.like('pact-broker-url-for-consumer-1-all')
                  },
                  {
                    href: Pact.like('pact-broker-url-for-consumer-2-all')
                  }
                ]
              }
            }
          )
      end

      it 'returns the array of pact urls' do
        pacts = Pact::PactBroker::FetchPacts.call(provider, tags, broker_base_url, basic_auth_options, all_pacts)

        expect(pacts).to eq(%w[pact-broker-url-for-consumer-1-all pact-broker-url-for-consumer-2-all])
      end
    end
  end
end