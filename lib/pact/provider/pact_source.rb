require 'pact/consumer_contract/pact_file'
require 'pact/hal/http_client'
require 'pact/hal/entity'
require 'pact/consumer_contract'

module Pact
  module Provider
    class PactSource

      attr_reader :uri # PactURI class

      def initialize uri
        @uri = uri
      end

      def pact_json
        @pact_json ||= Pact::PactFile.read(uri.uri, uri.options)
      end

      def pact_hash
        @pact_hash ||= JSON.load(pact_json, nil, { max_nesting: 50 })
      end

      def pending?
        uri.metadata[:pending]
      end

      def consumer_contract
        @consumer_contract ||= Pact::ConsumerContract.from_json(pact_json)
      end

      def hal_entity
        http_client_keys = [:username, :password, :token]
        http_client_options = uri.options.reject{ |k, _| !http_client_keys.include?(k) }
        http_client = Pact::Hal::HttpClient.new(http_client_options)
        Pact::Hal::Entity.new(uri, pact_hash, http_client)
      end
    end
  end
end
