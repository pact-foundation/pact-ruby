require 'pact/symbolize_keys'

module Pact
  class ServiceConsumer
    include SymbolizeKeys

    attr_accessor :name
    def initialize options
      @name = options[:name]
    end

    def to_s
      name
    end

    def to_hash
      {name: name}
    end

    def as_json options = {}
      to_hash
    end

    def self.from_hash hash
      new(symbolize_keys(hash))
    end
  end
end