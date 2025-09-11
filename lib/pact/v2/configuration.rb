# frozen_string_literal: true

module Pact
  module V2
    class Configuration
      attr_reader :before_provider_state_proc, :after_provider_state_proc

      class GlobalProviderConfigurationError < ::Pact::V2::Error; end

      def before_provider_state_setup(&block)
        raise GlobalProviderConfigurationError, "no block given" unless block

        @before_provider_state_proc = block
      end

      def after_provider_state_teardown(&block)
        raise GlobalProviderConfigurationError, "no block given" unless block

        @after_provider_state_proc = block
      end
    end
  end
end
