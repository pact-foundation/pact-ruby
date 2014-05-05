require 'pact/logging'
require 'rack/test'
require 'pact/consumer_contract/interaction'
require 'pact/provider/state/provider_state'
require 'pact/provider/state/provider_state_proxy'
require 'pact/provider/request'
require 'pact/provider/world'
require 'pact/provider/state/provider_state_manager'

module Pact
  module Provider
    module TestMethods

      include Pact::Logging
      include Rack::Test::Methods

      def replay_interaction interaction
        request = Request::Replayable.new(interaction.request)
        args = [request.path, request.body, request.headers]

        logger.info "Sending #{request.method.upcase} request to path: \"#{request.path}\" with headers: #{request.headers}, see debug logs for body"
        logger.debug "body :#{request.body}"
        response = self.send(request.method.downcase, *args)
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
        State::ProviderStateManager.new(provider_state_name, consumer).set_up_provider_state
      end

      def tear_down_provider_state provider_state_name, consumer
        State::ProviderStateManager.new(provider_state_name, consumer).tear_down_provider_state
      end

    end
  end
end
