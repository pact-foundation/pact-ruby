require_relative 'helper'
require 'pact/pact_broker/fetch_pacts'


describe Pact::PactBroker::FetchPacts, pact: true do

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
        .given('the relations for retrieving pacts exist in the index resource')
        .upon_receiving('a request for the index resource')
        .with(
          method: :get,
          path: '/',
          headers: get_headers
        )
        .will_respond_with(
          status: 200,
          headers: {
            'Content-Type' => Pact.term('application/hal+json', /json/)
          },
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
              }
            }
          }
        )
    end

    context 'retrieving latest pacts by provider' do
      let(:tags) { nil }

      before do
        pact_broker
          .given('consumer-1 and consumer-2 have pacts with provider provider-1')
          .upon_receiving('a request to retrieve the latest pacts for provider')
          .with(
            method: :get,
            path: '/pacts/provider/provider-1/latest',
            headers: get_headers
          )
          .will_respond_with(
            status: 200,
            headers: {
              'Content-Type' => Pact.term('application/hal+json', /json/)
            },
            body: {
              _links: {
                'pb:pacts' => [
                  {
                    href: Pact.term('http://pact-broker-url-for-consumer-1', %r{http://.*})
                  },
                  {
                    href: Pact.term('http://pact-broker-url-for-consumer-2', %r{http://.*})
                  }
                ]
              }
            }
          )
      end

      it 'returns the array of pact urls' do
        pacts = Pact::PactBroker::FetchPacts.call(provider, tags, broker_base_url, basic_auth_options)
        expect(pacts).to eq(
          [
            Pact::Provider::PactURI.new('http://pact-broker-url-for-consumer-1', basic_auth_options),
            Pact::Provider::PactURI.new('http://pact-broker-url-for-consumer-2', basic_auth_options)
          ]
        )
      end
    end

    context 'retrieving latest pacts by provider with the specified tag' do
      let(:tags) { ['tag-1', { name: 'tag-2', all: false }] }

      before do
        pact_broker
          .given('consumer-1 and consumer-2 have pacts with provider provider-1 tagged with tag-1')
          .upon_receiving('a request to retrieve the latest tagged (tag-1) pacts for provider')
          .with(
            method: :get,
            path: '/pacts/provider/provider-1/latest/tag-1',
            headers: get_headers
          )
          .will_respond_with(
            status: 200,
            headers: {
              'Content-Type' => Pact.term('application/hal+json', /json/)
            },
            body: {
              _links: {
                'pb:pacts' => [
                  {
                    href: Pact.term('http://pact-broker-url-for-consumer-1-tag-1', %r{http://.*})
                  },
                  {
                    href: Pact.term('http://pact-broker-url-for-consumer-2-tag-1', %r{http://.*})
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
          )
          .will_respond_with(
            status: 200,
            headers: {
              'Content-Type' => Pact.term('application/hal+json', /json/)
            },
            body: {
              _links: {
                'pb:pacts' => [
                  {
                    href: Pact.term('http://pact-broker-url-for-consumer-1-tag-2', %r{http://.*})
                  },
                  {
                    href: Pact.term('http://pact-broker-url-for-consumer-2-tag-2', %r{http://.*})
                  }
                ]
              }
            }
          )
      end

      it 'returns the array of pact urls' do
        pacts = Pact::PactBroker::FetchPacts.call(provider, tags, broker_base_url, basic_auth_options)

        expect(pacts).to eq(
          [
            Pact::Provider::PactURI.new('http://pact-broker-url-for-consumer-1-tag-1', basic_auth_options),
            Pact::Provider::PactURI.new('http://pact-broker-url-for-consumer-2-tag-1', basic_auth_options),
            Pact::Provider::PactURI.new('http://pact-broker-url-for-consumer-1-tag-2', basic_auth_options),
            Pact::Provider::PactURI.new('http://pact-broker-url-for-consumer-2-tag-2', basic_auth_options)
          ]
        )
      end
    end

    context 'retrieving latest pacts by provider with the fallback tag' do
      let(:tags) { [{ name: 'tag-1', all: false, fallback: 'master' }] }

      before do
        pact_broker
          .given('consumer-1 and consumer-2 have no pacts with provider provider-1 tagged with tag-1')
          .upon_receiving('a request to retrieve the latest tagged (tag-1) pacts for provider')
          .with(
            method: :get,
            path: '/pacts/provider/provider-1/latest/tag-1',
            headers: get_headers
          )
          .will_respond_with(
            status: 200,
            headers: {
              'Content-Type' => Pact.term('application/hal+json', /json/)
            },
            body: {
              _links: {
                'pb:pacts' => []
              }
            }
          )
        pact_broker
          .given('consumer-1 and consumer-2 have pacts with provider provider-1 tagged with master')
          .upon_receiving('a request to retrieve the latest tagged (master) pacts for provider')
          .with(
            method: :get,
            path: '/pacts/provider/provider-1/latest/master',
            headers: get_headers
          )
          .will_respond_with(
            status: 200,
            headers: {
              'Content-Type' => Pact.term('application/hal+json', /json/)
            },
            body: {
              _links: {
                'pb:pacts' => [
                  {
                    href: Pact.term('http://pact-broker-url-for-consumer-1-master', %r{http://.*})
                  },
                  {
                    href: Pact.term('http://pact-broker-url-for-consumer-2-master', %r{http://.*})
                  }
                ]
              }
            }
          )
      end

      it 'returns the array of pact urls' do
        pacts = Pact::PactBroker::FetchPacts.call(provider, tags, broker_base_url, basic_auth_options)
        expect(pacts).to eq(
          [
            Pact::Provider::PactURI.new('http://pact-broker-url-for-consumer-1-master', basic_auth_options),
            Pact::Provider::PactURI.new('http://pact-broker-url-for-consumer-2-master', basic_auth_options)
          ]
        )
      end
    end

    context 'when neither pacts are available for a tag nor fallback tag is available' do
      let(:tags) { ['tag-1'] }

      before do
        pact_broker
          .given('consumer-1 has no pacts with provider provider-1 tagged with tag-1')
          .upon_receiving('a request to retrieve the latest tagged (tag-1) pacts for provider')
          .with(
            method: :get,
            path: '/pacts/provider/provider-1/latest/tag-1',
            headers: get_headers
          )
          .will_respond_with(
            status: 200,
            headers: {
              'Content-Type' => Pact.term('application/hal+json', /json/)
            },
            body: {
              _links: {
                'pb:pacts' => []
              }
            }
          )
      end

      it 'returns empty array' do
        pacts = Pact::PactBroker::FetchPacts.call(provider, tags, broker_base_url, basic_auth_options)

        expect(pacts).to eq([])
      end
    end

    context 'retrieving all pact versions for tag-2 and latest pact versions for tag-1 for the provider with the specified consumer version tag' do
      let(:tags) { ['tag-1', { name: 'tag-2', all: true }] }

      before do
        pact_broker
          .given('consumer-1 and consumer-2 have 2 pacts with provider provider-1 tagged with tag-1')
          .upon_receiving('a request to retrieve latest pact versions for the provider with the specified consumer version tag (tag-1)')
          .with(
            method: :get,
            path: '/pacts/provider/provider-1/latest/tag-1',
            headers: get_headers
          )
          .will_respond_with(
            status: 200,
            headers: {
              'Content-Type' => Pact.term('application/hal+json', /json/)
            },
            body: {
              _links: {
                'pb:pacts' => [
                  {
                    href: Pact.term('http://pact-broker-url-for-consumer-1-tag-1', %r{http://.*})
                  },
                  {
                    href: Pact.term('http://pact-broker-url-for-consumer-2-tag-1', %r{http://.*})
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
          )
          .will_respond_with(
            status: 200,
            headers: {
              'Content-Type' => Pact.term('application/hal+json', /json/)
            },
            body: {
              _links: {
                'pb:pacts' => [
                  {
                    href: Pact.term('http://pact-broker-url-for-consumer-1-tag-2-all', %r{http://.*})
                  },
                  {
                    href: Pact.term('http://pact-broker-url-for-consumer-2-tag-2-all', %r{http://.*})
                  }
                ]
              }
            }
          )
      end

      it 'returns the array of pact urls' do
        pacts = Pact::PactBroker::FetchPacts.call(provider, tags, broker_base_url, basic_auth_options)

        expect(pacts).to eq(
          [
            Pact::Provider::PactURI.new('http://pact-broker-url-for-consumer-1-tag-1', basic_auth_options),
            Pact::Provider::PactURI.new('http://pact-broker-url-for-consumer-2-tag-1', basic_auth_options),
            Pact::Provider::PactURI.new('http://pact-broker-url-for-consumer-1-tag-2-all', basic_auth_options),
            Pact::Provider::PactURI.new('http://pact-broker-url-for-consumer-2-tag-2-all', basic_auth_options)
          ]
        )
      end
    end

    context 'retrieving all the latest pact versions for the specified provider' do
      let(:tags) { nil }

      before do
        pact_broker
          .given('consumer-1 and consumer-2 have 2 pacts with provider provider-1')
          .upon_receiving('a request to retrieve latest pacts for the specified provider')
          .with(
            method: :get,
            path: '/pacts/provider/provider-1/latest',
            headers: get_headers
          )
          .will_respond_with(
            status: 200,
            headers: {
              'Content-Type' => Pact.term('application/hal+json', /json/)
            },
            body: {
              _links: {
                'pb:pacts' => [
                  {
                    href: Pact.term('http://pact-broker-url-for-consumer-1-all', %r{http://.*})
                  },
                  {
                    href: Pact.term('http://pact-broker-url-for-consumer-2-all', %r{http://.*})
                  }
                ]
              }
            }
          )
      end

      it 'returns the array of pact urls' do
        pacts = Pact::PactBroker::FetchPacts.call(provider, tags, broker_base_url, basic_auth_options)

        expect(pacts).to eq(
          [
            Pact::Provider::PactURI.new('http://pact-broker-url-for-consumer-1-all', basic_auth_options),
            Pact::Provider::PactURI.new('http://pact-broker-url-for-consumer-2-all', basic_auth_options)
          ]
        )
      end
    end
  end
end
