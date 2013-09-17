module Pact
  module SymbolizeKeys

    def self.included(base)
      base.extend(self)
    end

    def symbolize_keys hash
      hash.inject({}) { |memo, (k,v)| memo[k.to_sym] = v; memo }
    end
  end
end