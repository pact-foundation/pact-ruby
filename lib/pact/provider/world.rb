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

      def add_pact_verification verification
        pact_verifications << verification
      end

      def pact_verifications
        @pact_verifications ||= []
      end

      def pact_urls
        pact_verifications.collect(&:uri)
      end

    end
  end
end