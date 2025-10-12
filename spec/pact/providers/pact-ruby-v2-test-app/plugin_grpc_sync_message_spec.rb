# frozen_string_literal: true

require 'pact/v2/rspec'

RSpec.describe 'Test grpc sync message plugin loading', :pact_v2 do
  has_plugin_sync_message_pact_between 'pact-ruby-v2-test-app', 'pact-ruby-v2-test-app', opts: { mock_port: 3009 }

  let(:pet_id) { 123 }

  let(:api) { ::PetStore::Grpc::PetStore::V1::Pets::Stub.new('localhost:3009', :this_channel_is_insecure) }
  let(:make_request) { api.pet_by_id(PetStore::Grpc::PetStore::V1::PetByIdRequest.new(id: pet_id)) }

  let(:interaction) do
    new_interaction
  end

  context 'with Pets/PetById' do
    context 'with successful interaction' do
      let(:interaction) do
        super()
          .given('pet exists', pet_id: pet_id)
          .with_plugin('protobuf', '0.6.5')
          .with_content_type('application/grpc')
          .with_transport('grpc')
          .with_plugin_metadata({
                                  'pact:proto' => File.expand_path('spec/internal/deps/services/pet_store/grpc/pet_store.proto'),
                                  'pact:proto-service' => 'Pets/PetById',
                                  'pact:content-type' => 'application/protobuf'
                                })
          .with_request(id: match_any_integer(pet_id))
          .will_respond_with(
            pet: {
              id: match_any_integer, name: match_any_string
            }
          )
      end

      it 'executes the pact test without errors' do
        interaction.execute do
          expect { make_request }.not_to raise_error
        end
      end
    end
  end
end
