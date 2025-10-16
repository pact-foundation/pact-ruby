require 'pact/v2/rspec'
require 'zoo_app/animal_service_client'

RSpec.describe 'ZooApp::AnimalServiceClient', :pact_v2 do
  has_http_pact_between 'Zoo App', 'Animal Service', opts: { pact_specification: 'V4' }

  subject { ZooApp::AnimalServiceClient }

  let(:alligator_name) { 'Mary' }
  let(:alligator_body) { { name: alligator_name } }
  let(:headers) { { 'Accept' => 'application/json' } }
  let(:content_headers) { { 'Content-Type' => 'application/json;charset=utf-8' } }

  describe 'Pact with Animal Service Provider' do
    let(:interaction) { new_interaction }

    describe '.find_alligator_by_name' do
      context 'when an alligator by the given name exists' do
        let(:interaction) do
          super()
            .given('there is an alligator named {alligator_name}', { alligator_name: alligator_name })
            .upon_receiving('a request for an alligator')
            .with_request(method: :get, path: generate_from_provider_state(expression: '/alligators/${alligator_name}',
                                                                           example: '/alligators/Mary'), headers: headers)
            .will_respond_with(status: 200, body: alligator_body, headers: content_headers)
        end

        it 'returns the alligator' do
          interaction.execute do |mock_server|
            ZooApp::AnimalServiceClient.base_uri(mock_server.url)
            expect(subject.find_alligator_by_name(alligator_name)).to eq ZooApp::Animals::Alligator.new(name: alligator_name)
          end
        end
      end

      context 'when an alligator by the given name does not exist' do
        let(:interaction) do
          super()
            .given("there is not an alligator named #{alligator_name}")
            .upon_receiving('a request for an alligator')
            .with_request(method: :get, path: "/alligators/#{alligator_name}", headers: headers)
            .will_respond_with(status: 404)
        end

        it 'returns nil' do
          interaction.execute do |mock_server|
            ZooApp::AnimalServiceClient.base_uri(mock_server.url)
            expect(subject.find_alligator_by_name(alligator_name)).to be_nil
          end
        end
      end

      context 'when an error occurs retrieving the alligator' do
        let(:interaction) do
          super()
            .given('an error occurs retrieving an alligator')
            .upon_receiving('a request for an alligator')
            .with_request(method: :get, path: "/alligators/#{alligator_name}", headers: headers)
            .will_respond_with(status: 500, body: { error: 'Argh!!!' }, headers: content_headers)
        end

        it 'raises an error' do
          interaction.execute do |mock_server|
            ZooApp::AnimalServiceClient.base_uri(mock_server.url)
            expect { subject.find_alligator_by_name(alligator_name) }.to raise_error(/Argh/)
          end
        end
      end
    end
  end
end
