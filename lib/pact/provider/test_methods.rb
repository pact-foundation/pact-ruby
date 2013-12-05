require 'pact/logging'
require 'rack/test'
require 'pact/consumer_contract/interaction'
require 'pact/provider/provider_state'
require 'pact/provider/provider_state_proxy'
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
        ProviderStateProxy.new.get(provider_state_name, :for => consumer)
      end
    end
  end
end
