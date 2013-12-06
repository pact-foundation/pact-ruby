module Pact
  module Provider
    class World

      def initialize configuration = Pact.configuration
        @configuration = configuration
      end

      def provider_states
        @provider_states_proxy ||= Pact::Provider::ProviderStateProxy.new(Pact::Provider::ProviderState)
      end


      private

      attr_reader :configuration

    end
  end
end