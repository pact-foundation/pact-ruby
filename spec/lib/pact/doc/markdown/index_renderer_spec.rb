require 'spec_helper'
require 'pact/doc/markdown/index_renderer'

module Pact
  module Doc
    module Markdown
      describe IndexRenderer do

        let(:consumer_name) { "Some Consumer" }
        let(:docs) {  {"Some Provider" => "Some Provider.md", "Some other provider" => "Some other provider.md"} }
        let(:subject) { IndexRenderer.new(consumer_name, docs) }
        let(:expected_content) { File.read('./spec/support/generated_index.md')}

        describe "#call" do
          it "renders the index" do
            expect(subject.call).to eq expected_content
          end
        end

        describe ".call" do
          it "renders the index" do
            expect(IndexRenderer.call(consumer_name, docs) ).to eq expected_content
          end
        end

      end
    end
  end
end