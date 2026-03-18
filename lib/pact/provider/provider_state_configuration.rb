# frozen_string_literal: true

module Pact
  module Provider
    class ProviderStateConfiguration
      attr_reader :name, :opts, :setup_proc, :teardown_proc

      class ProviderStateConfigurationError < ::Pact::Error; end

      def initialize(name, opts: {})
        @name = name
        @opts = opts
        @setup_proc = nil
        @teardown_proc = nil
      end

      def set_up(&block)
        @setup_proc = block
      end

      def tear_down(&block)
        @teardown_proc = block
      end

      def validate!
        return if @setup_proc || @teardown_proc

        raise ProviderStateConfigurationError.new("no hooks configured for state #{@name}: \"provider_state\" declaration only needed if setup/teardown hooks are used for that state. Please add hooks or remove \"provider_state\" declaration") # rubocop:disable Layout/LineLength
      end
    end
  end
end
