require 'spec_helper'
require 'pact/doc/markdown/interaction_renderer'

module Pact
  module Doc
    module Markdown
      describe InteractionRenderer do

        let(:consumer_contract) { Pact::ConsumerContract.from_uri './spec/support/markdown_pact.json' }
        subject { InteractionRenderer.new(consumer_contract.interactions.first, consumer_contract) }

        it "renders an interaction" do
          puts subject.render_summary
          puts subject.render_full_interaction
        end
      end

    end
  end
end


