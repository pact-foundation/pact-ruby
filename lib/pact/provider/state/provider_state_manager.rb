module Pact
  module Provider::State
    class ProviderStateManager

      attr_reader :provider_state_name, :params, :consumer

      def initialize provider_state_name, params, consumer
        @provider_state_name = provider_state_name
        @params = params
        @consumer = consumer
      end

      def set_up_provider_state
        get_global_base_provider_state.set_up(params)
        get_consumer_base_provider_state.set_up(params)
        if provider_state_name
          get_provider_state.set_up(params)
        end
      end

      def tear_down_provider_state
        if provider_state_name
          get_provider_state.tear_down(params)
        end
        get_consumer_base_provider_state.tear_down(params)
        get_global_base_provider_state.tear_down(params)
      end

      def get_provider_state
        Pact.provider_world.provider_states.get(provider_state_name, :for => consumer)
      end

      def get_consumer_base_provider_state
        Pact.provider_world.provider_states.get_base(:for => consumer)
      end

      def get_global_base_provider_state
        Pact.provider_world.provider_states.get_base
      end
    end
  end
end
