require 'pact/provider/state/provider_state_proxy'

module Pact

  def self.world
    @world ||= Pact::Provider::World.new
  end

  # internal api, for testing only
  def self.clear_world
    @world = nil
  end

  module Provider
    class World

      attr_reader :json_formatter_stream

      def initialize
        @json_formatter_stream = StringIO.new
      end

      def provider_states
        @provider_states_proxy ||= Pact::Provider::State::ProviderStateProxy.new
      end

    end
  end
end