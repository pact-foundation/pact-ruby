require 'spec_helper'
require 'pact/doc/markdown/consumer_contract_renderer'

module Pact
  module Doc
    module Markdown
      describe ConsumerContractRenderer do

        subject { ConsumerContractRenderer.new(consumer_contract) }
        let(:consumer_contract) { Pact::ConsumerContract.from_uri './spec/support/markdown_pact.json' }

        let(:expected_output) { File.read("./spec/support/generated_markdown.md") }

        describe "#call" do
          it "renders an interaction" do
            expect(subject.call).to eq(expected_output)
          end
        end

        describe ".call" do
          it "renders an interaction" do
            expect(ConsumerContractRenderer.call consumer_contract).to eq(expected_output)
          end
        end

      end
    end
  end
end