require 'spec_helper'
require 'pact/doc/markdown/interactions_renderer'

module Pact
  module Doc
    module Markdown
      describe InteractionsRenderer do

        subject { InteractionsRenderer.new(consumer_contract) }
        let(:consumer_contract) { Pact::ConsumerContract.from_uri './spec/support/markdown_pact.json' }

        describe "#render" do

          it "renders an interaction" do
            puts subject.render
          end
        end

      end
    end
  end
end