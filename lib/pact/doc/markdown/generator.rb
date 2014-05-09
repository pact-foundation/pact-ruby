require 'pact/doc/generator'
require 'pact/doc/markdown/consumer_contract_renderer'
require 'pact/doc/markdown/index_renderer'

module Pact
  module Doc
    module Markdown
      class Generator < Pact::Doc::Generator

        def initialize pact_dir, doc_dir
          super(pact_dir, doc_dir,
            consumer_contract_renderer: ConsumerContractRenderer,
            doc_type: 'markdown',
            file_extension: '.md',
            index_renderer: IndexRenderer,
            index_name: 'README')
        end

        def self.call pact_dir, doc_dir
          new(pact_dir, doc_dir).call
        end

      end
    end
  end
end