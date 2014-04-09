require 'pact/doc/generator'
require 'pact/doc/markdown/interactions_renderer'
require 'pact/doc/markdown/index_renderer'

module Pact
  module Doc
    module Markdown
      class Generator < Pact::Doc::Generator

        def initialize doc_root_dir, pact_dir
          super(doc_root_dir, pact_dir, InteractionsRenderer, 'markdown', '.md', IndexRenderer, 'README')
        end

      end
    end
  end
end