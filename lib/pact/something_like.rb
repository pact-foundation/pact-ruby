require 'pact/symbolize_keys'
module Pact

  # Specifies that the actual object should be considered a match if
  # it includes the same keys, and the values of the keys are of the same class.

  class SomethingLike
    include SymbolizeKeys

    attr_reader :contents

    def initialize contents
      @contents = contents
    end

    def to_hash
      {
        :json_class => self.class.name,
        :contents => contents
      }
    end

    def as_json opts = {}
      to_hash
    end

    def to_json opts = {}
      as_json.to_json opts
    end

    def self.json_create hash
      new(symbolize_keys(hash)[:contents])
    end

    def eq other
      self == other
    end

    def == other
      other.is_a?(SomethingLike) && other.contents == self.contents
    end

    def generate
      contents
    end
  end
end


