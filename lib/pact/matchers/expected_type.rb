require 'pact/matchers/difference_indicator'

module Pact
  class ExpectedType < Pact::DifferenceIndicator

    def initialize value
      @value = value
    end

    def type
      @value.class.name
    end

    def to_json options = {}
      type
    end

    def as_json options = {}
      type
    end

    def eq? other
      self.class == other.class && other.type == type
    end

    def == other
      eq? other
    end

    def to_s
      type
    end

  end
end