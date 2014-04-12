require 'pact/doc/generator'
require 'pact/doc/markdown/interactions_renderer'
require 'pact/doc/markdown/index_renderer'

module Pact
  module Doc
    module Markdown
      class Generator < Pact::Doc::Generator

        def initialize pact_dir, doc_root_dir
          super(pact_dir, doc_root_dir, InteractionsRenderer, 'markdown', '.md', IndexRenderer, 'README')
        end

        def self.call pact_dir, doc_root_dir
          new(pact_dir, doc_root_dir).call
        end

      end
    end
  end
end