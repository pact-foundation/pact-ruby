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

          context "with markdown characters in the pacticipant names" do
            let(:consumer_contract) { Pact::ConsumerContract.from_uri './spec/support/markdown_pact_with_markdown_chars_in_names.json' }

            it "escapes the markdown characters" do
              expect(subject.call).to include '### A pact between Some\*Consumer\*App and Some\_Provider\_App'
              expect(subject.call).to include '#### Requests from Some\*Consumer\*App to Some\_Provider\_App'
            end
          end

          it "renders the interactions" do
            expect(subject.call).to eq(expected_output)
          end
        end

      end
    end
  end
end