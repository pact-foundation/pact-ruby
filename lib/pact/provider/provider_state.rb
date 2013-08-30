module Pact
  module Provider

    module DSL
      def provider_state name, &block
        ProviderState.provider_state(name, &block).register
      end

      def with_consumer name, &block
        ProviderState.current_namespaces << name
        instance_eval(&block)
        ProviderState.current_namespaces.pop
      end

      alias_method :provider_states_for, :with_consumer
      alias_method :provider_state, :provider_state
    end

    class ProviderState

      attr_accessor :name
      attr_accessor :namespace

      def self.provider_state name, &block
        ProviderState.new(name, current_namespaces.join('.'), &block)
      end

      def self.register name, provider_state
        provider_states[name] = provider_state
      end

      def self.provider_states
        @@provider_states ||= {}
      end

      def self.current_namespaces
        @@current_namespaces ||= []
      end

      def self.get name, options = {}
        fullname = options[:for] ? "#{options[:for]}.#{name}" : name
        (provider_states[fullname] || provider_states[fullname.to_sym]) || provider_states[name]
      end

      def register
        self.class.register(namespaced(name), self)
      end

      def initialize name, namespace, &block
        @name = name
        @namespace = namespace
        instance_eval(&block)
      end

      def set_up &block
        if block_given?
          @set_up_block = block
        elsif @set_up_block
          instance_eval &@set_up_block
        end
      end

      def tear_down &block
        if block_given?
          @tear_down_block = block
        elsif @tear_down_block
          instance_eval &@tear_down_block
        end
      end

      private

      def namespaced(name)
        if namespace.empty?
          name
        else
          "#{namespace}.#{name}"
        end
      end
    end
  end
end
