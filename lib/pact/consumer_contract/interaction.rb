require 'pact/consumer_contract/request'
require 'pact/consumer_contract/response'
require 'pact/symbolize_keys'
require 'pact/shared/active_support_support'

module Pact
   class Interaction
    include ActiveSupportSupport
      include SymbolizeKeys

      attr_accessor :description, :request, :response, :provider_state

      def initialize attributes = {}
        @description = attributes[:description]
        @request = attributes[:request]
        @response = attributes[:response]
        @provider_state = attributes[:provider_state] || attributes[:providerState]
      end

      def self.from_hash hash
        request = Pact::Request::Expected.from_hash(hash['request'])
        response = Pact::Response.from_hash(hash['response'])
        new(symbolize_keys(hash).merge({request: request, response: response}))
      end

      def to_hash
        hash = { :description => @description }
        hash[:provider_state] = @provider_state if @provider_state #Easier to read when provider state at top
        hash.merge(:request => @request.as_json, :response => @response)
      end

      def as_json options = {}
        fix_all_the_things to_hash
      end

      def to_json(options = {})
        as_json.to_json(options)
      end

      def matches_criteria? criteria
        criteria.each do | key, value |
          unless match_criterion self.send(key.to_s), value
            return false
          end
        end
        true
      end

      def match_criterion target, criterion
        target == criterion || (criterion.is_a?(Regexp) && criterion.match(target))
      end

      def == other
        other.is_a?(Interaction) && as_json == other.as_json
      end

      def eq? other
        self == other
      end

      def description_with_provider_state_quoted
        provider_state ? "\"#{description}\" given \"#{provider_state}\"" : "\"#{description}\""
      end

      def request_modifies_resource_without_checking_response_body?
        request.modifies_resource? && response.body_allows_any_value?
      end

      def to_s
        JSON.pretty_generate(self)
      end
   end
end