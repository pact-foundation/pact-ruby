require 'pact/logging'
require 'rack/test'
require 'pact/reification'
require 'pact/provider/provider_state'

module Pact
  module Provider
    module TestMethods

      include Pact::Logging
      include Rack::Test::Methods

      def parse_entity_from_response response
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

      def replay_interaction interaction
        request = interaction.request
        path = request_path(request)
        args = [path, request_body(request)]

        if !request.headers.nil?
          args << request_headers(request)
        end

        logger.debug "Sending #{request.method} with #{args}"
        self.send(request.method, *args)
      end

      private

      def request_headers request
        request_headers = {}
        request.headers.each do |key, value|
          key = key.upcase
          if key.match(/CONTENT.TYPE/)
            request_headers['CONTENT_TYPE'] = value
          else
            request_headers['HTTP_' + key.to_s] = value
          end
        end
        request_headers
      end

      def request_path request
        path = request.path
        query = request.query
        if query && !query.empty?
          path += "?" + request.query
        end
        path
      end

      def request_body request
        body = request.body
        if body
          body = JSON.dump(Pact::Reification.from_term(body))
        else
          body = ""
        end
      end

      def get_provider_state provider_state_name, consumer
        unless provider_state = ProviderState.get(provider_state_name, :for => consumer)
          extra = consumer ? " for consumer \"#{consumer}\"" : ""
          raise "Could not find a provider state defined for \"#{provider_state_name}\"#{extra}. Have you required the provider state file in your spec?"
        end
        provider_state
      end
    end
  end
end
