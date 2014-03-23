module Pact
  module TaskHelper

    extend self

    def handle_verification_failure
      exit_status = yield
      abort if exit_status != 0
    end

    def spec_criteria defaults = {description: nil, provider_state: nil}
      criteria = {}

      description = ENV.fetch("PACT_DESCRIPTION", defaults[:description])
      criteria[:description] = Regexp.new(description) if description

      provider_state = ENV.fetch("PACT_PROVIDER_STATE", defaults[:provider_state])
      if provider_state
        if provider_state.length == 0
          criteria[:provider_state] = nil #Allow PACT_PROVIDER_STATE="" to mean no provider state
        else
          criteria[:provider_state] = Regexp.new(provider_state)
        end
      end

      criteria
    end
  end
end