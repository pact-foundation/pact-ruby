module Pact
  module Provider::State
    class ProviderStateProxy

      attr_reader :missing_provider_states

      def initialize
        @missing_provider_states = {}
      end

      def get name, options = {}
        unless provider_state = ProviderStates.get(name, options)
          register_missing_provider_state name, options[:for]
          raise error_message name, options[:for]
        end
        provider_state
      end

      def get_base options = {}
        ProviderStates.get_base options
      end

      private

      def error_message name, consumer
        "Could not find provider state \"#{name}\" for consumer #{consumer}"
      end

      def register_missing_provider_state name, consumer
        missing_states_for(consumer) << name unless missing_states_for(consumer).include?(name)
      end

      def missing_states_for consumer
        @missing_provider_states[consumer] ||= []
      end

    end
  end
end
