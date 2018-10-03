require 'pact/provider/state/provider_state_manager'

module Pact
  module Provider
    module State
      class SetUp
        def self.call provider_state_name, consumer, options = {}
          State::ProviderStateManager.new(provider_state_name, options[:params], consumer).set_up_provider_state
        end
      end
    end
  end
end
