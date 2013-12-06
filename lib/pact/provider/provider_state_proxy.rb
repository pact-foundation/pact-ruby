module Pact
  module Provider
    class ProviderStateProxy

      attr_reader :missing_provider_states

      def initialize
        @missing_provider_states = {}
      end

      def get name, options = {}
        unless provider_state = ProviderState.get(name, options)
          register_missing_provider_state name, options[:for]
          raise error_message name, options[:for]
        end
        provider_state
      end

      private

      def error_message name, consumer
        ERB.new(template_string).result(binding)
      end

      def template_string
        File.read(File.expand_path( '../../templates/provider_state.erb', __FILE__))
      end


      def register_missing_provider_state name, consumer
        missing_states_for(consumer) << name
      end

      def missing_states_for consumer
        @missing_provider_states[consumer] ||= []
      end

    end
  end
end
