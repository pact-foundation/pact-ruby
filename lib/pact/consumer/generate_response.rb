require 'randexp'

module Pact
  module Consumer
    module GenerateResponse

      def self.from_term(term)
        case
        when term.respond_to?(:generate)
          term.generate
        when term.is_a?(Hash)
          term.inject({}) do |mem, (key,term)|
            mem[key] = from_term(term)
            mem
          end
        when term.is_a?(Array)
          term.inject([]) do |mem, term|
            mem << from_term(term)
            mem
          end
        else
          term
        end
      end

    end
  end
end
