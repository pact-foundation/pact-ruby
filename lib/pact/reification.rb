require 'randexp'

module Pact
  module Reification

    def self.from_term(term)
      case term
      when Pact::Term, Regexp, Pact::SomethingLike
        term.generate
      when Hash
        term.inject({}) do |mem, (key,term)|
          mem[key] = from_term(term)
        mem
        end
      when Array
        term.inject([]) do |mem, term|
          mem << from_term(term)
          mem
        end
      when Pact::Request::Base
        from_term(term.to_hash)
      else
        term
      end
    end

  end
end
