require 'pact/consumer_contract/pact_file'

module Pact
  module Provider
    class PactSource

      attr_reader :uri

      def initialize uri
        @uri = uri
      end

      def pact_json
        @pact_json ||= Pact::PactFile.read(uri.uri, uri.options)
      end

      def pact_hash
        @pact_hash ||= JSON.load(pact_json, nil, { max_nesting: 50 })
      end
    end
  end
end
