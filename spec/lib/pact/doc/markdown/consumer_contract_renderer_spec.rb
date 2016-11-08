require 'spec_helper'
require 'pact/doc/markdown/consumer_contract_renderer'

module Pact
  module Doc
    module Markdown
      describe ConsumerContractRenderer do

        subject { ConsumerContractRenderer.new(consumer_contract) }
        let(:consumer_contract) { Pact::ConsumerContract.from_uri './spec/support/markdown_pact.json' }

        let(:expected_output) { File.read("./spec/support/generated_markdown.md", external_encoding: Encoding::UTF_8) }

        describe "#call" do

          context "with markdown characters in the pacticipant names" do
            let(:consumer_contract) { Pact::ConsumerContract.from_uri './spec/support/markdown_pact_with_markdown_chars_in_names.json' }

            it "escapes the markdown characters" do
              expect(subject.call).to include '### A pact between Some\*Consumer\*App and Some\_Provider\_App'
              expect(subject.call).to include '#### Requests from Some\*Consumer\*App to Some\_Provider\_App'
            end
          end

          context "with ruby's default external encoding is not UTF-8" do
            around do |example|
              back = nil
              WarningSilencer.enable { back, Encoding.default_external = Encoding.default_external, Encoding::ASCII_8BIT }
              example.run
              WarningSilencer.enable { Encoding.default_external = back }
            end

            it "renders the interactions" do
              expect(subject.call).to eq(expected_output)
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
