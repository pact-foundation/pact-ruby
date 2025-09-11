# frozen_string_literal: true

describe Pact::V2::Provider::GrufServer do
  let(:api) { ::PetStore::Grpc::PetStore::V1::Pets::Stub.new("localhost:3009", :this_channel_is_insecure) }
  let(:call_rpc) do
    subject.run { api.pet_by_id(PetStore::Grpc::PetStore::V1::PetByIdRequest.new(id: 1)) }
  end

  context "when success" do
    it "succeeds" do
      resp = call_rpc

      expect(resp.pet.id).to eq 1
      expect(resp.pet.name).to eq "Jack"
    end
  end
end
