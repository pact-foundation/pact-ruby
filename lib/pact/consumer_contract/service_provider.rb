require 'pact/symbolize_keys'

module Pact
  class ServiceProvider
    include SymbolizeKeys

    attr_accessor :name
    def initialize options
      @name = options[:name] || '[provider name unknown - please update the pact gem in the consumer project to the latest version and regenerate the pacts]'
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