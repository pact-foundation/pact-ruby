require 'uri'
require 'json/add/regexp'
require 'pact/json_warning'
require 'pact/logging'

module Pact
  module Consumer
    class MockProducer

      include Pact::JsonWarning
      include Pact::Logging

      attr_reader :uri
      attr_reader :consumer_contract

      def initialize(pactfile_root)
        @pactfile_root = pactfile_root
        @interactions = {}
        @producer_state = nil
        @consumer_contract = Pact::ConsumerContract.new
      end

      def consumer(consumer_name)
        consumer_contract.consumer = ServiceConsumer.new(name: consumer_name) 
        self
      end

      def assuming_a_service(service_name)
        consumer_contract.producer = ServiceProducer.new(name: service_name)
        self
      end

      def at(url, options = {})
        @uri = URI(url)
        raise "You must first configure a producer" unless (consumer_contract.producer && consumer_contract.producer.name)
        unless options[:standalone]
          AppManager.instance.register_mock_service_for consumer_contract.producer.name, url
        end
        self
      end

      def on_port(port, options = {})
        at("http://localhost:#{port}", options)
      end

      def given(producer_state)
        @producer_state = producer_state
        self
      end

      def upon_receiving(description)
        interaction_builder = InteractionBuilder.new(self, description, @producer_state)
        @interactions["#{description} given #{@producer_state}"] ||= interaction_builder.interaction
        consumer_contract.interactions = @interactions.values
        interaction_builder
      end

      def update_pactfile
        logger.debug "Updating pact file for #{consumer_contract.producer.name} at #{pactfile_path}"
        check_for_active_support_json
        File.open(pactfile_path, 'w') do |f|
          f.write JSON.pretty_generate(consumer_contract)
        end
      end

      def pactfile_path
        raise 'You must first specify a consumer and service name' unless consumer_contract.consumer and consumer_contract.producer
        @pactfile_path ||= File.join(@pactfile_root, consumer_contract.pact_file_name)
      end

      def verify
        http = Net::HTTP.new(uri.host, uri.port)
        response = http.request_get('/verify')
        raise response.body unless response.is_a? Net::HTTPSuccess
      end

      private

      def filenamify name
        name.downcase.gsub(/\s/, '_')
      end

    end
  end
end
