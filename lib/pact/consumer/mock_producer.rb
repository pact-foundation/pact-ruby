require 'uri'
require 'json/add/core'

module Pact
  module Consumer
    class MockProducer

      attr_reader :uri

      def initialize(pactfile_root)
        @pactfile_root = pactfile_root
        @interactions = {}
      end

      def consumer(consumer_name)
        @consumer_name = consumer_name
        self
      end

      def assuming_a_service(service_name)
        @service_name = service_name
        self
      end

      def at(url)
        @uri = URI(url)
        self
      end

      def upon_receiving(description)
        @interactions[description] ||= Interaction.new(self, description)
      end

      def update_pactfile
        File.open(pactfile_path, 'w') do |f|
          f.write JSON.dump(@interactions.values)
        end
      end

      def pactfile_path
        raise 'You must first specify a consumer and service name' unless @consumer_name and @service_name
        @pactfile_path ||= File.join(@pactfile_root, "#{filenamify(@consumer_name)}-#{filenamify(@service_name)}.json")
      end

      private

      def filenamify name
        name.downcase.gsub(/\s/, '_')
      end

    end
  end
end
