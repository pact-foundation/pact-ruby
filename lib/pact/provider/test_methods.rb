require 'pact/logging'
require 'rack/test'
require 'pact/request'
require 'pact/provider/provider_state'

module Pact
  module Provider
    module TestMethods

      include Pact::Logging
      include Rack::Test::Methods

      def replay_interaction interaction
        request = Request::Replayable.new(interaction.request)
        args = [request.path, request.body, request.headers]

        logger.debug "Sending #{request.method} with #{args}"
        self.send(request.method, *args)
      end

      def parse_body_from_response response
        case response.headers['Content-Type']
        when /json/
          JSON.load(response.body)
        else
          response.body
        end
      end

      def set_up_provider_state provider_state_name, consumer
        if provider_state_name
          get_provider_state(provider_state_name, consumer).set_up
        end
      end

      def tear_down_provider_state provider_state_name, consumer
        if provider_state_name
          get_provider_state(provider_state_name, consumer).tear_down
        end
      end

      def get_provider_state provider_state_name, consumer
        unless provider_state = ProviderState.get(provider_state_name, :for => consumer)
          extra = consumer ? " for consumer \"#{consumer}\"" : ""
          error_msg = <<-eos
Could not find a provider state named \"#{provider_state_name}\"#{extra}.
Have you required the provider states file for this consumer in your pact_helper.rb?
Check the name in the Pact.provider_states_for definition is exactly \"#{consumer}\"
eos
          raise error_msg
        end
        provider_state
      end
    end
  end
end
