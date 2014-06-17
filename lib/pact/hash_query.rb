require 'pact/symbolize_keys'

module Pact
  class HashQuery
    include Pact::SymbolizeKeys

    attr_reader :query

    def self.json_create(obj)
      new(obj['data']['query'])
    end

    def initialize(query)
      @query = query
    end

    def ==(other)
      if other.is_a?(HashQuery)
        query == other.query
      else
        symbolize_keys(query) == symbolize_keys(Rack::Utils.parse_nested_query(other))
      end
    end

    def to_hash
      { json_class: self.class.name, data: { query: query } }
    end

    def as_json(options = {})
      to_hash
    end

    def to_s
      Rack::Utils.build_query(query)
    end

    def empty?
      query.empty?
    end
  end
end