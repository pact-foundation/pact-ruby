# frozen_string_literal: true

require "pact/v2/rspec"

RSpec.describe "Pact::V2::Consumers::Http", :pact_v2 do
  mixed_pact_provider "pact-v2-test-app", opts: {
    http: {
      http_port: 3000,
      log_level: :info,
      pact_dir: File.expand_path('../../pacts', __dir__),
    },
    grpc: {
      grpc_port: 3009
    },
    async: {
      message_handlers: {
        # "pet message as json" => proc do |provider_state|
        #   pet_id = provider_state.dig("params", "pet_id")
        #   with_pact_producer { |client| PetJsonProducer.new(client: client).call(pet_id) }
        # end,
        # "pet message as proto" => proc do |provider_state|
        #   pet_id = provider_state.dig("params", "pet_id")
        #   with_pact_producer { |client| PetProtoProducer.new(client: client).call(pet_id) }
        # end
      }
    }
  }

  handle_message "pet message as json" do |provider_state|
    pet_id = provider_state.dig("params", "pet_id")
    with_pact_producer { |client| PetJsonProducer.new(client: client).call(pet_id) }
  end

  handle_message "pet message as proto" do |provider_state|
    pet_id = provider_state.dig("params", "pet_id")
    with_pact_producer { |client| PetProtoProducer.new(client: client).call(pet_id) }
  end
  
end
