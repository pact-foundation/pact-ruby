module Pact

  def self.world
    @world ||= Pact::Provider::World.new
  end

  module Provider
    class World

      def initialize
      end

      def provider_states
        @provider_states_proxy ||= Pact::Provider::ProviderStateProxy.new
      end

    end
  end
end