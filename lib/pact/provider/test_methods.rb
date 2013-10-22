require 'pact/logging'
require 'rack/test'
require 'pact/consumer_contract/interaction'
require 'pact/provider/provider_state'
require 'pact/provider/request'

module Pact
  module Provider
    module TestMethods

      include Pact::Logging
      include Rack::Test::Methods

      def replay_interaction interaction
        request = Request::Replayable.new(interaction.request)
        args = [request.path, request.body, request.headers]

        logger.info "Sending #{request.method} request to path: \"#{request.path}\" with headers: #{request.headers}, see debug logs for body"
        logger.debug "body :#{request.body}"
        response = self.send(request.method, *args)
        logger.info "Received response with status: #{response.status}, headers: #{response.headers}, see debug logs for body"
        logger.debug "body: #{response.body}"
      end

      def parse_body_from_response rack_response
        case rack_response.headers['Content-Type']
        when /json/
          JSON.load(rack_response.body)
        else
          rack_response.body
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
If you have not yet defined a provider state for \"#{provider_state_name}\", here is a template:

Pact.provider_states_for \"#{consumer}\" do
  provider_state \"#{provider_state_name}\" do
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
