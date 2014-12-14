require 'pact/consumer_contract/pact_file'

module PactBroker
  module Provider
    module Verification

      def self.new uri, options
        Instance.new(uri, options)
      end

      class Instance

        attr_reader :uri, :options

        def initialize uri, options
          @uri = uri
          @options = options
        end

        def consumer_name
          consumer_contract.consumer.name
        end

        def provider_name
          consumer_contract.provider.name
        end

        def consumer_contract
          @consumer_contract ||= Pact::ConsumerContract.from_json(pact_json)
        end

        def pact_json
          @pact_json ||= Pact::PactFile.read(uri, options)
        end

        private

      end
    end
  end
end
