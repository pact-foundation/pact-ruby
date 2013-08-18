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
      attr_reader :pactfile_write_mode

      def initialize(fields)
        @interactions = {}
        @producer_state = nil
        @pactfile_write_mode = fields[:pactfile_write_mode]
        @consumer_contract = Pact::ConsumerContract.new(
          :consumer => ServiceConsumer.new(name: fields[:consumer_name]),
          :producer => ServiceProducer.new(name: fields[:producer_name])
          )
        if pactfile_write_mode == :update && File.exist?(consumer_contract.pactfile_path)
          load_existing_pactfile
        end
      end

      def load_existing_pactfile
        json = File.read(consumer_contract.pactfile_path)
        if json.size > 0
          existing_consumer_contract = Pact::ConsumerContract.from_json json
          existing_consumer_contract.interactions.each do | interaction |
            @interactions["#{interaction.description} given #{interaction.producer_state}"] = interaction
          end
          consumer_contract.interactions = @interactions.values
        end
      end

      def on_port(port)
        @uri = URI("http://localhost:#{port}")
        self
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
        consumer_contract.update_pactfile
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
