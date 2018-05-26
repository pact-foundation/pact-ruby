require 'pact/pact_broker/fetch_pacts'

module Pact
  module PactBroker
    describe('call') do
      let(:provider) { 'provider-name' }
      let(:broker_base_url) { 'https://pact.broker.com.au/' }
      let(:basic_auth_options) { { username: 'foo', password: 'bar' } }
      let(:tags) { [] }
      let(:http_client) do
        instance_double('Pact::Hal::HttpClient', get: response)
      end
      let(:index_entity) do
        instance_double('Pact::Hal::Entity')
      end
      let(:link) do
        instance_double('Pact::Hal::Link')
      end
      let(:link_for_tag_1) do
        instance_double('Pact::Hal::Link', get: pact_entity_for_tag_1)
      end
      let(:pact_entity_for_tag_1) do
        instance_double('Pact::Hal::Entity', fetch: [{ 'href' => 'pact-brker-url-for-consumer-1-tag-1' },
                                                     { 'href' => 'pact-brker-url-for-consumer-2-tag-1' }])
      end
      let(:link_for_tag_2) do
        instance_double('Pact::Hal::Link', get: pact_entity_for_tag_2)
      end
      let(:pact_entity_for_tag_2) do
        instance_double('Pact::Hal::Entity', fetch: [{ 'href' => 'pact-brker-url-for-consumer-1-tag-2' },
                                                     { 'href' => 'pact-brker-url-for-consumer-2-tag-2' }])
      end
      let(:link_for_provider_without_tag) do
        instance_double('Pact::Hal::Link', get: pact_entity_for_provider_without_tag)
      end
      let(:pact_entity_for_provider_without_tag) do
        instance_double('Pact::Hal::Entity', fetch: [{ 'href' => 'pact-brker-url-for-consumer-1' },
                                                     { 'href' => 'pact-brker-url-for-consumer-2' }])
      end
      let(:response) do
        instance_double('Pact::Hal::HttpClient::Response', success?: true, body: {
                          '_links' => {
                            'self' => {
                              'href' => broker_base_url
                            },
                            'pb:latest-provider-pacts' => {
                              'href' => 'https://pact.broker.com.au/pacts/provider/{provider}/latest',
                              'title' => 'Latest pacts by provider'
                            },
                            'pb:latest-provider-pacts-with-tag' => {
                              'href' => 'https://pact.broker.com.au/pacts/provider/{provider}/latest/{tag}',
                              'title' => 'Latest pacts by provider with the specified tag'
                            }
                          }
                        })
      end
      let(:broker_response) do
        {
          '_links' => {
            'self' => {
              'href' => broker_base_url
            },
            'pb:latest-provider-pacts' => {
              'href' => 'https://pact.broker.com.au/pacts/provider/{provider}/latest',
              'title' => 'Latest pacts by provider'
            },
            'pb:latest-provider-pacts-with-tag' => {
              'href' => 'https://pact.broker.com.au/pacts/provider/{provider}/latest/{tag}',
              'title' => 'Latest pacts by provider with the specified tag'
            }
          }
        }.to_json
      end
      let(:pact_entities_for_provider) do
        {
          '_links' => {
            'pacts' => [
              {
                'href' => 'pact-brker-url-for-consumer-1',
                'title' => 'Pact between consumer-1-name (v1.0.625) and provider-name',
                'name' => 'consumer-1-name'
              },
              {
                'href' => 'pact-brker-url-for-consumer-2',
                'title' => 'Pact between consumer-2-name (v1.0.1138) and provider-name',
                'name' => 'consumer-2-name'
              }
            ]
          }
        }.to_json
      end

      before do
        allow(Pact::Hal::HttpClient).to receive(:new)
          .with(basic_auth_options).and_return(http_client)
        allow(Pact::Hal::Entity).to receive(:new)
          .with(response.body, http_client).and_return(index_entity)
      end

      subject do
        FetchPacts.call(provider, tags, broker_base_url, basic_auth_options)
      end

      context 'when tags are provided' do
        let(:tags) { %w[tag-1 tag-2] }
        before do
          allow(index_entity).to receive(:_link).with('pb:latest-provider-pacts-with-tag')
                                                .and_return(link)
          allow(link).to receive(:expand).with(provider: provider, tag: 'tag-1')
                                         .and_return(link_for_tag_1)
          allow(link).to receive(:expand).with(provider: provider, tag: 'tag-2')
                                         .and_return(link_for_tag_2)
        end

        it 'creates new http client' do
          expect(Pact::Hal::HttpClient).to receive(:new).with(basic_auth_options)
          subject
        end

        it 'creates new HAL entity' do
          expect(Pact::Hal::Entity).to receive(:new)
            .with(response.body, http_client)
          subject
        end

        context 'when pacts are available' do
          it 'returns an arrays of pact urls based on provider name and tag\'s latest version' do
            expect(subject).to eq(%w[pact-brker-url-for-consumer-1-tag-1 pact-brker-url-for-consumer-2-tag-1 pact-brker-url-for-consumer-1-tag-2 pact-brker-url-for-consumer-2-tag-2])
          end
        end

        context 'when there are no pacts for the specified tags' do
          let(:pact_entity_for_tag_1) do
            instance_double('Pact::Hal::Entity', fetch: [])
          end

          let(:pact_entity_for_tag_2) do
            instance_double('Pact::Hal::Entity', fetch: [])
          end

          it 'returns an empty array' do
            expect(subject).to eq([])
          end
        end
      end

      context 'when tags are either nil or empty array' do
        before do
          allow(index_entity).to receive(:_link).with('pb:latest-provider-pacts').and_return(link)
          allow(link).to receive(:expand).with(provider: provider).and_return(link_for_provider_without_tag)
        end

        context 'when tags are nil' do
          let(:tags) { nil }

          it 'returns array of the latest pact urls for the provider' do
            expect(subject).to eq(%w[pact-brker-url-for-consumer-1 pact-brker-url-for-consumer-2])
          end
        end

        context 'when the tags array is empty' do
          let(:tags) { nil }

          it 'returns array of the latest pact urls for the provider' do
            expect(subject).to eq(%w[pact-brker-url-for-consumer-1 pact-brker-url-for-consumer-2])
          end
        end
      end
    end
  end
end
