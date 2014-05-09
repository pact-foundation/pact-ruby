module Pact
  module Doc

    class DocFile

      def initialize consumer_contract, dir, consumer_contract_renderer, file_extension
        @dir = dir
        @consumer_contract = consumer_contract
        @consumer_contract_renderer = consumer_contract_renderer
        @file_extension = file_extension
      end

      def write
        File.open(path, "w") { |io|  io << doc_file_contents }
      end

      def title
        consumer_contract.provider.name
      end

      def name
        "#{consumer_contract.consumer.name} - #{consumer_contract.provider.name}#{file_extension}"
      end

      private

      attr_reader :dir, :consumer_contract, :consumer_contract_renderer, :file_extension


      def path
        File.join(dir, name)
      end

      def doc_file_contents
        consumer_contract_renderer.call(consumer_contract)
      end

    end
  end
end