require 'pact/pact_broker/fetch_pacts'

module Pact
  module PactBroker
    describe('call') do
      let(:provider) {'provider-name'}
      let(:broker_base_url) {'https://pact.broker.com.au/'}
      let(:basic_auth_options) {{username: 'foo', password: 'bar'}}
      let!(:broker_request) do
        stub_request(:get, broker_base_url)
          .with(headers: {
            Accept: 'application/hal+json',
            Authorization: 'Basic Zm9vOmJhcg=='
          })
          .to_return(status: 200, body: broker_response,
                     headers: {'Content-Type' => 'application/json'})
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

      context 'when tags are provided' do
        let(:tags) {%w[tag-1 tag-2]}

        context 'when pacts are available' do
          let(:pact_entities_for_tag_1) do
            {
              '_links' => {
                'pacts' => [
                  {
                    'href' => 'pact-brker-url-for-consumer-1-tag-1',
                    'title' => 'Pact between consumer-1-name (v1.0.625) and provider-name',
                    'name' => 'consumer-1-name'
                  },
                  {
                    'href' => 'pact-brker-url-for-consumer-2-tag-1',
                    'title' => 'Pact between consumer-2-name (v1.0.1138) and provider-name',
                    'name' => 'consumer-2-name'
                  }]
              }
            }.to_json
          end

          let(:pact_entities_for_tag_2) do
            {
              '_links' => {
                'pacts' => [
                  {
                    'href' => 'pact-brker-url-for-consumer-1-tag-2',
                    'title' => 'Pact between consumer-1-name (v1.0.625) and provider-name',
                    'name' => 'consumer-1-name'
                  },
                  {
                    'href' => 'pact-brker-url-for-consumer-2-tag-2',
                    'title' => 'Pact between consumer-2-name (v1.0.1138) and provider-name',
                    'name' => 'consumer-2-name'
                  }]
              }
            }.to_json
          end

          let!(:provider_tag_request) do
            stub_request(:get, 'https://pact.broker.com.au/pacts/provider/provider-name/latest/tag-1')
              .with(headers: {
                'Accept' => 'application/hal+json',
                'Authorization' => 'Basic Zm9vOmJhcg=='
              })
              .to_return(status: 200, body: pact_entities_for_tag_1, headers: {'Content-Type' => 'application/json'})

            stub_request(:get, 'https://pact.broker.com.au/pacts/provider/provider-name/latest/tag-2')
              .with(headers: {
                'Accept' => 'application/hal+json',
                'Authorization' => 'Basic Zm9vOmJhcg=='
              })
              .to_return(status: 200, body: pact_entities_for_tag_2, headers: {'Content-Type' => 'application/json'})
          end

          subject do
            FetchPacts.call(provider, tags, broker_base_url, basic_auth_options)
          end

          it 'makes a get request to broker base url' do
            subject
            expect(WebMock).to have_requested(:get, broker_base_url)
          end

          it 'makes a get request for the latest pacts for each tag' do
            subject
            expect(WebMock).to have_requested(:get, 'https://pact.broker.com.au/pacts/provider/provider-name/latest/tag-1')
            expect(WebMock).to have_requested(:get, 'https://pact.broker.com.au/pacts/provider/provider-name/latest/tag-2')
          end

          it "returns an arrays of pact urls based on provider name and tag's latest version" do
            expect(subject).to eq(%w(pact-brker-url-for-consumer-1-tag-1 pact-brker-url-for-consumer-2-tag-1 pact-brker-url-for-consumer-1-tag-2 pact-brker-url-for-consumer-2-tag-2))
          end
        end

        context 'when there are no pacts for the specified tags' do
          let(:pact_entities_for_tag_1) do
            {
              '_links' => {
                'pacts' => []
              }
            }.to_json
          end

          let(:pact_entities_for_tag_2) do
            {
              '_links' => {
                'pacts' => []
              }
            }.to_json
          end

          let!(:provider_tag_request) do
            stub_request(:get, 'https://pact.broker.com.au/pacts/provider/provider-name/latest/tag-1')
              .with(headers: {
                'Accept' => 'application/hal+json',
                'Authorization' => 'Basic Zm9vOmJhcg=='
              })
              .to_return(status: 200, body: pact_entities_for_tag_1, headers: {'Content-Type' => 'application/json'})

            stub_request(:get, 'https://pact.broker.com.au/pacts/provider/provider-name/latest/tag-2')
              .with(headers: {
                'Accept' => 'application/hal+json',
                'Authorization' => 'Basic Zm9vOmJhcg=='
              })
              .to_return(status: 200, body: pact_entities_for_tag_2, headers: {'Content-Type' => 'application/json'})
          end

          subject do
            FetchPacts.call(provider, tags, broker_base_url, basic_auth_options)
          end

          it 'returns an empty array' do
            @result = subject
            expect(@result).to be_a Array
            expect(@result).to eq([])
          end
        end
      end

      context 'when tags is nil' do
        let(:pact_entities_for_provider_name) do
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
                }]
            }
          }.to_json
        end

        let!(:provider_request) do
          stub_request(:get, 'https://pact.broker.com.au/pacts/provider/provider-name/latest')
            .with(headers: {
              'Accept' => 'application/hal+json',
              'Authorization' => 'Basic Zm9vOmJhcg=='
            })
            .to_return(status: 200, body: pact_entities_for_provider_name, headers: {'Content-Type' => 'application/json'})
        end

        subject do
          FetchPacts.call(provider, nil, broker_base_url, basic_auth_options)
        end

        it 'makes a get request to broker base url' do
          subject
          expect(WebMock).to have_requested(:get, broker_base_url)
        end

        it 'makes a get request to provider url' do
          subject
          expect(WebMock).to have_requested(:get, 'https://pact.broker.com.au/pacts/provider/provider-name/latest')
        end

        it 'returns array of pact urls by provider' do
          @result = subject
          expect(@result).to be_a Array
          expect(@result).to eq(%w(pact-brker-url-for-consumer-1 pact-brker-url-for-consumer-2))
        end
      end

      context 'when the tags array is empty' do
        let!(:provider_request) do
          stub_request(:get, 'https://pact.broker.com.au/pacts/provider/provider-name/latest')
            .to_return(status: 200, body: pact_entities_for_provider_name, headers: {'Content-Type' => 'application/json'})
        end

        let(:pact_entities_for_provider_name) do
          {
            '_links' => {
              'pacts' => []
            }
          }.to_json
        end

        subject do
          FetchPacts.call(provider, [], broker_base_url, basic_auth_options)
        end

        it 'fetches the latest pacts without tags' do
          subject
          expect(WebMock).to have_requested(:get, 'https://pact.broker.com.au/pacts/provider/provider-name/latest')
        end
      end
    end
  end
end