# frozen_string_literal: true

module PetStore
  class PetStoreController < Gruf::Controllers::Base
    bind PetStore::Grpc::PetStore::V1::Pets::Service

    def pet_by_id
      req = request.message
      PetStore::Grpc::PetStore::V1::PetResponse.new(pet: {id: req.id, name: "Jack"}, metadata: request.metadata)
    end
  end
end
