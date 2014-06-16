require 'pact/symbolize_keys'

module Pact
  class HashQuery
    include Pact::SymbolizeKeys

    def initialize(query)
      @query = query
    end

    def ==(other)
      symbolize_keys(@query) == symbolize_keys(Rack::Utils.parse_nested_query(other))
    end
  end
end