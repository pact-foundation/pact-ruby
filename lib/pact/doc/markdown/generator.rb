require 'pact/doc/generator'
require 'pact/doc/markdown/interactions_renderer'
require 'fileutils'

module Pact
  module Doc
    module Markdown
      class Generator < Pact::Doc::Generator

        def initialize doc_root_dir, pact_dir
          super(doc_root_dir, pact_dir, InteractionsRenderer, 'markdown', '.md')
        end

      end
    end
  end
end