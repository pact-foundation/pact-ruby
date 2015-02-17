require 'pact/cli'
require 'pact/cli/generate_pact_docs'
require 'pact/doc/generator'

module Pact
  describe CLI do
    describe "docs" do

      let(:docs) { subject.invoke :docs }

      before do
        allow(Pact::Doc::Generate).to receive(:call)
      end

      it "generates Markdown documentation" do
        expect(Pact::Doc::Generate).to receive(:call).with(anything, anything, [Pact::Doc::Markdown::Generator])
        docs
      end

      context "with no arguments" do

        subject { CLI.new }

        it 'uses the default Pact configuration for pact_dir and doc_dir' do
          expect(Pact::Doc::Generate).to receive(:call).with(Dir.pwd + '/spec/pacts', Dir.pwd + '/doc/pacts', anything)
          docs
        end
      end

      context "with a pact_dir specified" do

        subject { CLI.new([], pact_dir: 'pacts') }

        it 'uses the specified pact_dir' do
          expect(Pact::Doc::Generate).to receive(:call).with('pacts', anything, anything)
          docs
        end
      end

      context "with a doc_dir specified" do

        subject { CLI.new([], doc_dir: 'docs') }

        it 'uses the specified doc_dir' do
          expect(Pact::Doc::Generate).to receive(:call).with(anything, 'docs', anything)
          docs
        end
      end
    end
  end
end
