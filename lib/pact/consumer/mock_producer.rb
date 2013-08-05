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

      def initialize(pactfile_root)
        @pactfile_root = pactfile_root
        @interactions = {}
        @producer_state = nil
      end

      def consumer(consumer_name)
        @consumer_name = consumer_name
        self
      end

      def assuming_a_service(service_name)
        @service_name = service_name
        self
      end

      def at(url, options = {})
        @uri = URI(url)
        raise "You must first specify a service name" unless @service_name
        unless options[:standalone]
          AppManager.instance.register_mock_service_for @service_name, url
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
        @interactions["#{description} given #{@producer_state}"] ||= Interaction.new(self, description, @producer_state)
      end

      def update_pactfile
        logger.debug "Updating pact file for #{@service_name} at #{pactfile_path}"
        check_for_active_support_json
        File.open(pactfile_path, 'w') do |f|
          f.write JSON.pretty_generate(pact)
        end
      end

      def pactfile_path
        raise 'You must first specify a consumer and service name' unless @consumer_name and @service_name
        @pactfile_path ||= File.join(@pactfile_root, "#{filenamify(@consumer_name)}-#{filenamify(@service_name)}.json")
      end

      private

      def pact
        Pact::ConsumerContract.new(:interactions => @interactions.values)
      end

      def filenamify name
        name.downcase.gsub(/\s/, '_')
      end

    end
  end
end
