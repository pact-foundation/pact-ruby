module Pact
  module Doc
    class Generate

      def self.call pact_dir  = Pact.configuration.pact_dir, doc_dir = Pact.configuration.doc_dir, doc_generators = Pact.configuration.doc_generators
        doc_generators.each{| doc_generator| doc_generator.call pact_dir, doc_dir }
      end

    end
  end
end