require 'pact/doc/doc_file'
require 'fileutils'

module Pact
  module Doc

    class Generator

      def initialize pact_dir, doc_dir, options
        @doc_dir = doc_dir
        @pact_dir = pact_dir
        @consumer_contract_renderer = options[:consumer_contract_renderer]
        @doc_type = options[:doc_type]
        @file_extension = options[:file_extension]
        @index_renderer = options[:index_renderer]
        @index_name = options[:index_name]
        @after = options.fetch(:after, lambda{|pact_dir, target_dir, consumer_contracts| })
      end

      def call
        ensure_target_dir_exists_and_is_clean
        write_index if consumer_contracts.any?
        write_doc_files
        perform_after_hook
      end

      private

      attr_reader :doc_dir, :pact_dir, :consumer_contract_renderer, :doc_type, :file_extension, :index_renderer, :after

      def write_index
        File.open(index_file_path, "w") { |io|  io << index_file_contents }
      end

      def index_file_path
        File.join(target_dir, "#{@index_name}#{file_extension}")
      end

      def index_file_contents
        index_renderer.call(consumer_contracts.first.consumer.name, index_data)
      end

      def index_data
        doc_files.each_with_object({}) do | doc_file, data |
          data[doc_file.title] = doc_file.name
        end
      end

      def write_doc_files
        doc_files.each(&:write)
      end

      def doc_files
        consumer_contracts.collect do | consumer_contract |
          DocFile.new(consumer_contract, target_dir, consumer_contract_renderer, file_extension)
        end
      end

      def consumer_contracts
        @consumer_contracts ||= begin
          Dir.glob("#{pact_dir}/**").collect do |file|
            Pact::ConsumerContract.from_uri file
          end
        end
      end

      def perform_after_hook
        after.call(pact_dir, target_dir, consumer_contracts)
      end

      def ensure_target_dir_exists_and_is_clean
        FileUtils.rm_rf target_dir
        FileUtils.mkdir_p target_dir
      end

      def target_dir
        File.join(doc_dir, doc_type)
      end

    end
  end
end