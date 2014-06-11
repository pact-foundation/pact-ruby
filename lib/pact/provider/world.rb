require 'pact/provider/state/provider_state_proxy'

module Pact

  def self.provider_world
    @world ||= Pact::Provider::World.new
  end

  # internal api, for testing only
  def self.clear_provider_world
    @world = nil
  end

  module Provider
    class World

      def provider_states
        @provider_states_proxy ||= Pact::Provider::State::ProviderStateProxy.new
      end

    end
  end
end