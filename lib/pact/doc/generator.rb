require 'pact/doc/doc_file'
require 'fileutils'

module Pact
  module Doc

    class Generator

      attr_reader :doc_root_dir, :pact_dir, :interactions_renderer, :doc_type, :file_extension, :index_renderer

      def initialize doc_root_dir, pact_dir, interactions_renderer, doc_type, file_extension, index_renderer, index_name
        @doc_root_dir = doc_root_dir
        @pact_dir = pact_dir
        @interactions_renderer = interactions_renderer
        @doc_type = doc_type
        @file_extension = file_extension
        @index_renderer = index_renderer
        @index_name = index_name
      end

      def call
        ensure_target_dir_exists
        write_index if consumer_contracts.any?
        write_doc_files
      end

      def write_index
        File.open(index_file_path, "w") { |io|  io << index_file_contents }
      end

      def write_doc_files
        doc_files.each(&:write)
      end

      def index_file_contents
        index_renderer.call(consumer_contracts.first.consumer.name, index_data)
      end

      def index_data
        doc_files.each_with_object({}) do | doc_file, data |
          data[doc_file.title] = doc_file.name
        end
      end

      def doc_files
        consumer_contracts.collect do | consumer_contract |
          DocFile.new(consumer_contract, target_dir, interactions_renderer, file_extension)
        end
      end

      def consumer_contracts
        @consumer_contracts ||= begin
          Dir.glob("#{pact_dir}/**").collect do |file|
            consumer_contract_from(file)
          end
        end
      end

      def consumer_contract_from file
        Pact::ConsumerContract.from_uri file
      end

      def index_file_path
        File.join(target_dir, "#{@index_name}#{file_extension}")
      end

      def ensure_target_dir_exists
        FileUtils.mkdir_p target_dir
      end

      def target_dir
        File.join(doc_root_dir, doc_type)
      end

      def == other
        other.is_a?(self.class) && other.doc_root_dir == doc_root_dir && other.pact_dir == pact_dir
      end

    end
  end
end