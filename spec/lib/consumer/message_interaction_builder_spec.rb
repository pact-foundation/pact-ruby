# frozen_string_literal: true

RSpec.describe Pact::Consumer::MessageInteractionBuilder do
  subject { described_class.new(nil) }

  context 'when proto message is used' do
    let(:proto_path) { 'spec/internal/deps/services/pet_store/grpc/pet_store.proto' }
    let(:builder) do
      subject
        .upon_receiving('message as proto')
        .with_proto_class(proto_path, 'Pet')
        .with_proto_contents(id: 1)
    end

    it 'builds proper json' do
      result = JSON.parse(builder.build_interaction_json)
      expect(result).to eq(
        'pact:content-type' => 'application/protobuf',
        'pact:message-type' => 'Pet',
        'pact:proto' => File.expand_path(proto_path).to_s,
        'id' => 1
      )
    end
  end

  context 'when json message is used' do
    let(:proto_path) { 'spec/internal/deps/services/pet_store/grpc/pet_store.proto' }
    let(:builder) do
      subject
        .upon_receiving('message as proto')
        .with_json_contents(id: 1)
    end

    it 'builds proper json' do
      result = JSON.parse(builder.build_interaction_json)
      expect(result).to eq('id' => 1)
    end
  end
end
