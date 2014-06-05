require 'pact/consumer/mock_service/mock_service_administration_endpoint'
require 'pact/consumer_contract/consumer_contract_writer'

module Pact
  module Consumer
    class PactPost < MockServiceAdministrationEndpoint

      attr_accessor :consumer_contract, :interactions

      def initialize name, logger, interactions
        super name, logger
        @interactions = interactions
      end

      def request_path
        '/pact'
      end

      def request_method
        'POST'
      end

      def respond env
        logger.info "Writing pact BLAH"
        consumer_contract_details = JSON.parse(env['rack.input'].string, symbolize_names: true)
        consumer_contract_writer = ConsumerContractWriter.new(consumer_contract_details.merge(interactions: interactions), logger)
        json = consumer_contract_writer.write

        [200, {'Content-Type' =>'application/json'}, [json]]
      end
    end
  end
end
