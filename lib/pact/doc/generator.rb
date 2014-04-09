require 'pact/doc/markdown/interactions_renderer'
require 'fileutils'
require 'pact/doc/doc_file'

module Pact
  module Doc

    class Generator

      attr_reader :doc_root_dir, :pact_dir, :interactions_renderer, :doc_type, :file_extension

      def initialize doc_root_dir, pact_dir, interactions_renderer, doc_type, file_extension
        @doc_root_dir = doc_root_dir
        @pact_dir = pact_dir
        @interactions_renderer = interactions_renderer
        @doc_type = doc_type
        @file_extension = file_extension
      end

      def call
        ensure_target_dir_exists
        write_doc_files
        # create_index
      end

      # def create_index
      #   #File.open(doc_file_path(consumer_contract), "w") { |io|  io << index_file_contents }
      # end

      def write_doc_files
        doc_files.each(&:write)
      end

      # def index_file_contents

      # end

      def doc_files
        Dir.glob("#{pact_dir}/**").collect do |file|
          DocFile.new(consumer_contract_from(file), target_dir, interactions_renderer, file_extension)
        end
      end

      def consumer_contract_from file
        Pact::ConsumerContract.from_uri file
      end

      # def index_file_path
      #   File.join(target_dir, "#{@index_name}#{file_extension}")
      # end

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