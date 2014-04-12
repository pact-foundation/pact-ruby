require 'spec_helper'
require 'pact/doc/generator'
require 'fileutils'

module Pact
  module Doc
    describe Generator do

      let(:doc_root_dir) { './tmp/doc' }
      let(:pact_dir) { './tmp/pacts' }
      let(:file_name) { "Some Consumer - Some Provider#{file_extension}" }
      let(:interactions_renderer) { double("InteractionsRenderer", :call => doc_content) }
      let(:doc_content) { "doc_content" }
      let(:index_content) { "index_content" }
      let(:expected_doc_path) { "#{doc_root_dir}/#{doc_type}/#{file_name}" }
      let(:expected_index_path) { "#{doc_root_dir}/#{doc_type}/#{index_name}#{file_extension}" }
      let(:doc_type) { 'markdown' }
      let(:file_extension) { ".md" }
      let(:actual_file_contents) { File.read(expected_doc_path) }
      let(:actual_index_contents) { File.read(expected_index_path)}
      let(:index_renderer) { double("IndexRenderer", :call => index_content)}
      let(:index_name) { 'README' }

      before do
        FileUtils.rm_rf doc_root_dir
        FileUtils.rm_rf pact_dir
        FileUtils.mkdir_p doc_root_dir
        FileUtils.mkdir_p pact_dir
        FileUtils.cp './spec/support/markdown_pact.json', pact_dir
      end

      subject { Generator.new(pact_dir, doc_root_dir, interactions_renderer: interactions_renderer, doc_type: doc_type, file_extension: file_extension, index_renderer: index_renderer, index_name: index_name) }

      it "creates an index" do
        subject.call
        expect(actual_index_contents).to eq(index_content)
      end

      it "creates documentation" do
        subject.call
        expect(actual_file_contents).to eq(doc_content)
      end

    end
  end
end