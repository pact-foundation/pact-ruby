module Pact
  module Cli
    class SpecCriteria

      def self.call options
        criteria = {}

        criteria[:description] = Regexp.new(options[:description]) if options[:description]

        provider_state = options[:provider_state]
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
end
