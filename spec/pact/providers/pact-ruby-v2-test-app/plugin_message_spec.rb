# frozen_string_literal: true

require 'pact/rspec'

# Message pacts whose contents come from a plugin without a transport, via #with_plugin / #with_plugin_contents
RSpec.describe 'Test plugin message contents without a transport', :pact, skip_windows: true do
  has_message_pact_between 'pact-ruby-test-app-plugin-message-consumer', 'pact-ruby-test-app-plugin-message-provider'

  context 'with the protobuf plugin' do
    let(:interaction) do
      new_interaction
        .given('pet exists', pet_id: 1)
        .upon_receiving('pet message as proto via with_plugin')
        .with_plugin('protobuf', Pact::Consumer::MessageInteractionBuilder::PROTOBUF_PLUGIN_VERSION)
        .with_plugin_contents(
          'application/protobuf',
          'pact:proto' => File.expand_path('spec/internal/deps/services/pet_store/grpc/pet_store.proto'),
          'pact:message-type' => 'Pet',
          id: match_any_integer(1),
          name: match_any_string('some pet')
        )
        .with_metadata(topic: match_any_string('some-topic'))
    end

    it 'executes the pact test without errors' do
      interaction.execute do |payload, meta|
        pet = PetStore::Grpc::PetStore::V1::Pet.decode(payload)
        expect(pet.id).to eq(1)
        expect(pet.name).to eq('some pet')
        expect(meta).to include('topic' => 'some-topic',
                                'contentType' => 'application/protobuf;message=.pet_store.v1.Pet')
      end
    end
  end

  context 'with the avro plugin' do
    let(:avro_plugin_dir) do
      File.join(ENV.fetch('PACT_PLUGIN_DIR', File.join(Dir.home, '.pact/plugins')), 'avro-0.1.3')
    end

    before { skip "the avro plugin isn't installed in #{avro_plugin_dir}" unless File.directory?(avro_plugin_dir) }

    let(:interaction) do
      new_interaction
        .given('pet exists', pet_id: 1)
        .upon_receiving('pet message as avro')
        .with_plugin('avro', '0.1.3')
        .with_plugin_contents(
          'avro/binary',
          'pact:avro' => File.expand_path('spec/internal/deps/services/pet_store/avro/pet.avsc'),
          'pact:record-name' => 'Pet',
          id: "notEmpty('1')",
          name: "notEmpty('some pet')"
        )
        .with_metadata(topic: match_any_string('some-topic'))
    end

    it 'executes the pact test without errors' do
      interaction.execute do |payload, meta|
        # Avro binary: zigzag long 1, then the string's zigzag length 8 and its bytes
        expect(payload.b).to eq("\x02\x10some pet".b)
        expect(meta).to include('topic' => 'some-topic')
      end
    end
  end
end
