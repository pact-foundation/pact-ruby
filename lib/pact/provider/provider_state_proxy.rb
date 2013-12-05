module Pact
  module Provider
    class ProviderStateProxy

      def get name, options = {}
        unless provider_state = ProviderState.get(name, options)
          consumer = options[:for]
          extra = consumer ? " for consumer \"#{consumer}\"" : ""
          error_msg = <<-eos
Could not find a provider state named \"#{name}\"#{extra}.
Have you required the provider states file for this consumer in your pact_helper.rb?
If you have not yet defined a provider state for \"#{name}\", here is a template:

Pact.provider_states_for \"#{consumer}\" do
  provider_state \"#{name}\" do
    set_up do
      # Your set up code goes here
    end
  end
end
eos
          raise error_msg
        end
        provider_state
      end

    end
  end
end
