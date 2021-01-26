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

      attr_accessor :pact_sources, :failed_examples, :verbose

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
        (pact_verifications.collect(&:uri) + pact_uris_from_pact_uri_sources).compact
      end

      def add_pact_uri_source pact_uri_source
        pact_uri_sources << pact_uri_source
      end

      private

      def pact_uri_sources
        @pact_uri_sources ||= []
      end

      def pact_uris_from_pact_uri_sources
        pact_uri_sources.collect(&:call).flatten
      end
    end
  end
end
