module Pact
  module Doc

    class DocFile

      def initialize consumer_contract, dir, interactions_renderer, file_extension
        @dir = dir
        @consumer_contract = consumer_contract
        @interactions_renderer = interactions_renderer
        @file_extension = file_extension
      end

      def write
        File.open(path, "w") { |io|  io << doc_file_contents }
      end

      private

      attr_reader :dir, :consumer_contract, :interactions_renderer, :file_extension

      def name
        "#{consumer_contract.consumer.name} - #{consumer_contract.provider.name}#{file_extension}"
      end

      def path
        File.join(dir, name)
      end

      def doc_file_contents
        interactions_renderer.call(consumer_contract)
      end

    end
  end
end