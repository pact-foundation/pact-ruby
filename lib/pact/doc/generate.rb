module Pact
  module Doc
    class Generate

      def self.call doc_generators = Pact.configuration.doc_generators
        doc_generators.each(&:call)
      end

    end
  end
end