require 'pact/consumer_contract/pact_file'

module PactBroker
  module Provider
    class PactSource

      attr_reader :uri

      def initialize uri
        @uri = uri
      end

      def pact_json
        @pact_json ||= Pact::PactFile.read(uri.uri, uri.options)
      end

    end
  end
end
