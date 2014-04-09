require 'spec_helper'
require 'pact/doc/generator'
require 'fileutils'

module Pact
  module Doc
    describe Generator do

      let(:doc_root_dir) { './tmp/doc' }
      let(:pact_dir) { './tmp/pacts' }
      let(:file_name) { "Some Consumer - Some Provider#{file_extension}" }
      let(:interaction_renderer) { double("InteractionsRenderer", :call => doc_content) }
      let(:doc_content) { "doc_content" }
      let(:expected_doc_path) { "#{doc_root_dir}/#{doc_type}/#{file_name}" }
      let(:doc_type) { 'markdown' }
      let(:file_extension) { ".md" }
      let(:actual_file_contents) { File.read(expected_doc_path) }

      before do
        FileUtils.rm_rf doc_root_dir
        FileUtils.rm_rf pact_dir
        FileUtils.mkdir_p doc_root_dir
        FileUtils.mkdir_p pact_dir
        FileUtils.cp './spec/support/markdown_pact.json', pact_dir
      end

      subject { Generator.new(doc_root_dir, pact_dir, interaction_renderer, doc_type, file_extension) }

      it "creates documentation" do
        subject.call
        expect(actual_file_contents).to eq(doc_content)
      end

    end
  end
end