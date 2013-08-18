require 'uri'
require 'json/add/regexp'
require 'pact/json_warning'
require 'pact/logging'

module Pact
  module Consumer
    class ConsumerContractBuilder

      include Pact::JsonWarning
      include Pact::Logging

      attr_reader :uri
      attr_reader :consumer_contract
      attr_reader :pactfile_write_mode

      def initialize(attributes)
        @interactions = {}
        @producer_state = nil
        @pactfile_write_mode = attributes[:pactfile_write_mode]
        @consumer_contract = Pact::ConsumerContract.new(
          :consumer => ServiceConsumer.new(name: attributes[:consumer_name]),
          :producer => ServiceProducer.new(name: attributes[:producer_name])
          )
        @uri = URI("http://localhost:#{attributes[:port]}")
        @http = Net::HTTP.new(uri.host, uri.port)
        if pactfile_write_mode == :update && File.exist?(consumer_contract.pactfile_path)
          load_existing_interactions
        end
      end

      def load_existing_interactions
        json = File.read(consumer_contract.pactfile_path)
        if json.size > 0
          existing_consumer_contract = Pact::ConsumerContract.from_json json
          existing_consumer_contract.interactions.each do | interaction |
            @interactions["#{interaction.description} given #{interaction.producer_state}"] = interaction
          end
          consumer_contract.interactions = @interactions.values
        end
      end

      def given(producer_state)
        @producer_state = producer_state
        self
      end

      def upon_receiving(description)
        interaction_builder = InteractionBuilder.new(description, @producer_state)
        producer = self
        interaction_builder.on_interaction_fully_defined do | interaction |
          producer.handle_interaction_fully_defined(interaction)
        end
        @interactions["#{description} given #{@producer_state}"] ||= interaction_builder.interaction
        consumer_contract.interactions = @interactions.values
        interaction_builder
      end

      def handle_interaction_fully_defined interaction
        @http.request_post('/interactions', interaction.to_json_with_generated_response)
        @producer_state = nil
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
