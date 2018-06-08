require 'pact/consumer/rspec'
require 'pact/pact_broker/fetch_pacts'

Pact.service_consumer "Pact Ruby" do
  has_pact_with "Pact Broker" do
    mock_service :pact_broker do
      port 1234
      pact_specification_version "2.0.0"
    end
  end
end

describe Pact::PactBroker::FetchPacts, pact: true do

  let(:get_headers) {{:Accept => 'application/hal+json'}}

  describe "fetch pacts" do
    let(:provider) {'provider-name'}
    let(:broker_base_url) {'http://localhost:1234/'}
    let(:basic_auth_options) {{username: 'foo', password: 'bar'}}

    before do
      pact_broker
        .given('all the relations exists in the index resource')
        .upon_receiving('a request for the index resource')
        .with(
          method: :get,
          path: '/',
          headers: get_headers
        ).
        will_respond_with(
          status: 200,
          headers: {},
          body: {
            _links: {
              self: {
                href: broker_base_url
              },
              'pb:latest-provider-pacts' => {
                href: 'http://localhost:1234/pacts/provider/{provider}/latest',
                title: 'Latest pacts by provider'
              },
              'pb:latest-provider-pacts-with-tag' => {
                'href' => 'http://localhost:1234/pacts/provider/{provider}/latest/{tag}',
                'title' => 'Latest pacts by provider with the specified tag'
              },
              :'pb:provider-pacts-with-tag' => {
                'href' => 'http://localhost:1234/pacts/provider/{provider}/tag/{tag}',
                'title' => 'All pact versions for the provider with the specified consumer version tag'
              },
              'pb:provider-pacts' => {
                'href' => 'http://localhost:1234/pacts/provider/{provider}',
                'title' => 'All pact versions for the specified provider'
              }
            }
          }
        )
    end

    context 'retrieving latest pacts by provider' do
      let(:tags) {nil}
      let(:all_pacts) {false}

      before do
        pact_broker
          .given('pacts exist between consumer and provider')
          .upon_receiving('a request to retrieve the latest pacts for provider')
          .with(
            method: :get,
            path: '/pacts/provider/provider-name/latest',
            headers: get_headers
          ).
          will_respond_with(
            status: 200,
            headers: {},
            body: {
              _links: {
                self: {
                  href: 'http://localhost:1234/pacts/provider/provider-name/latest',
                  title: 'Latest pact versions for the provider'},
                provider: {
                  href: 'http://localhost:1234/pacticipants/provider-name',
                  'title': 'provider-name'
                },
                pacts: [
                  {'href': 'pact-brker-url-for-consumer-1'
                  },
                  {'href': 'pact-broker-url-for-consumer-2'
                  }
                ]
              }
            }
          )
      end

      it 'returns the array of pact urls' do
        pacts = Pact::PactBroker::FetchPacts.call(provider, tags, broker_base_url, basic_auth_options, all_pacts)

        expect(pacts).to eq(%w(pact-brker-url-for-consumer-1 pact-broker-url-for-consumer-2))
      end
    end

    context 'retrieving latest pacts by provider with the specified tag' do
      let(:tags) {%w[tag-1 tag-2]}
      let(:all_pacts) {false}

      before do
        pact_broker
          .given('pacts exist between consumer and provider')
          .upon_receiving('a request to retrieve the latest tagged (tag-1) pacts for provider')
          .with(
            method: :get,
            path: '/pacts/provider/provider-name/latest/tag-1',
            headers: get_headers
          ).
          will_respond_with(
            status: 200,
            headers: {},
            body: {
              _links: {
                self: {
                  href: 'http://localhost:1234/pacts/provider/provider-name/latest/tag-1',
                  title: 'Latest pacts by provider with the specified tag'},
                provider: {
                  href: 'http://localhost:1234/pacticipants/provider-name',
                  'title': 'provider-name'
                },
                pacts: [
                  {'href': 'pact-brker-url-for-consumer-1-tag-1'
                  },
                  {'href': 'pact-brker-url-for-consumer-2-tag-1'
                  }
                ]
              }
            }
          )
        pact_broker
          .given('pacts exist between consumer and provider')
          .upon_receiving('a request to retrieve the latest tagged (tag-2) pacts for provider')
          .with(
            method: :get,
            path: '/pacts/provider/provider-name/latest/tag-2',
            headers: get_headers
          ).
          will_respond_with(
            status: 200,
            headers: {},
            body: {
              _links: {
                self: {
                  href: 'http://localhost:1234/pacts/provider/provider-name/latest/tag-2',
                  title: 'Latest pacts by provider with the specified tag'},
                provider: {
                  href: 'http://localhost:1234/pacticipants/provider-name',
                  'title': 'provider-name'
                },
                pacts: [
                  {'href': 'pact-brker-url-for-consumer-1-tag-2'
                  },
                  {'href': 'pact-brker-url-for-consumer-2-tag-2'
                  }
                ]
              }
            }
          )
      end

      it 'returns the array of pact urls' do
        pacts = Pact::PactBroker::FetchPacts.call(provider, tags, broker_base_url, basic_auth_options, all_pacts)

        expect(pacts).to eq(%w(pact-brker-url-for-consumer-1-tag-1 pact-brker-url-for-consumer-2-tag-1
            pact-brker-url-for-consumer-1-tag-2 pact-brker-url-for-consumer-2-tag-2))
      end
    end

    context 'retrieving all pact versions for the provider with the specified consumer version tag' do
      let(:tags) {%w[tag-1 tag-2]}
      let(:all_pacts) {true}

      before do
        pact_broker
          .given('pacts exist between consumer and provider')
          .upon_receiving('a request to retrieve all pact versions for the provider with the specified consumer version tag (tag-1)')
          .with(
            method: :get,
            path: '/pacts/provider/provider-name/tag/tag-1',
            headers: get_headers
          ).
          will_respond_with(
            status: 200,
            headers: {},
            body: {
              _links: {
                self: {
                  href: 'http://localhost:1234/pacts/provider/provider-name/tag/tag-1',
                  title: 'All pact versions for the provider with the specified consumer version tag'},
                provider: {
                  href: 'http://localhost:1234/pacticipants/provider-name',
                  'title': 'provider-name'
                },
                pacts: [
                  {'href': 'pact-brker-url-for-consumer-1-tag-1-all'
                  },
                  {'href': 'pact-brker-url-for-consumer-2-tag-1-all'
                  }
                ]
              }
            }
          )
        pact_broker
          .given('pacts exist between consumer and provider')
          .upon_receiving('a request to retrieve all pact versions for the provider with the specified consumer version tag (tag-2)')
          .with(
            method: :get,
            path: '/pacts/provider/provider-name/tag/tag-2',
            headers: get_headers
          ).
          will_respond_with(
            status: 200,
            headers: {},
            body: {
              _links: {
                self: {
                  href: 'http://localhost:1234/pacts/provider/provider-name/tag/tag-2',
                  title: 'All pact versions for the provider with the specified consumer version tag'},
                provider: {
                  href: 'http://localhost:1234/pacticipants/provider-name',
                  'title': 'provider-name'
                },
                pacts: [
                  {'href': 'pact-brker-url-for-consumer-1-tag-2-all'
                  },
                  {'href': 'pact-brker-url-for-consumer-2-tag-2-all'
                  }
                ]
              }
            }
          )
      end

      it 'returns the array of pact urls' do
        pacts = Pact::PactBroker::FetchPacts.call(provider, tags, broker_base_url, basic_auth_options, all_pacts)

        expect(pacts).to eq(%w(pact-brker-url-for-consumer-1-tag-1-all pact-brker-url-for-consumer-2-tag-1-all
            pact-brker-url-for-consumer-1-tag-2-all pact-brker-url-for-consumer-2-tag-2-all))
      end
    end

    context 'retrieving all pact versions for the specified provider' do
      let(:tags) {nil}
      let(:all_pacts) {true}

      before do
        pact_broker
          .given('pacts exist between consumer and provider')
          .upon_receiving('a request to retrieve all pact versions for the specified provider')
          .with(
            method: :get,
            path: '/pacts/provider/provider-name',
            headers: get_headers
          ).
          will_respond_with(
            status: 200,
            headers: {},
            body: {
              _links: {
                self: {
                  href: 'http://localhost:1234/pacts/provider/provider-name',
                  title: 'All pact versions for the specified provider'},
                provider: {
                  href: 'http://localhost:1234/pacticipants/provider-name',
                  'title': 'provider-name'
                },
                pacts: [
                  {'href': 'pact-brker-url-for-consumer-1-all'
                  },
                  {'href': 'pact-brker-url-for-consumer-2-all'
                  }
                ]
              }
            }
          )
      end

      it 'returns the array of pact urls' do
        pacts = Pact::PactBroker::FetchPacts.call(provider, tags, broker_base_url, basic_auth_options, all_pacts)

        expect(pacts).to eq(%w(pact-brker-url-for-consumer-1-all pact-brker-url-for-consumer-2-all))
      end
    end
  end
end