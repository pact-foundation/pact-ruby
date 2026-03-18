# frozen_string_literal: true

require 'pact/rspec'

RSpec.describe 'PactProviders::Test::GrpcClient', :pact do
  has_grpc_pact_between 'pact-ruby-test-app', 'pact-ruby-test-app'

  let(:pet_id) { 123 }

  let(:api) { ::PetStore::Grpc::PetStore::V1::Pets::Stub.new('localhost:3009', :this_channel_is_insecure) }
  let(:make_request) { api.pet_by_id(PetStore::Grpc::PetStore::V1::PetByIdRequest.new(id: pet_id)) }

  let(:interaction) do
    new_interaction
      .with_service('spec/internal/deps/services/pet_store/grpc/pet_store.proto', 'Pets/PetById')
  end

  context 'with Pets/PetById' do
    context 'with successful interaction' do
      let(:interaction) do
        super()
          .given('pet exists', pet_id: pet_id)
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
