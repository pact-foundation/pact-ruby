require 'pact/matchers/expected_type'


module Pact
  class ActualType < Pact::ExpectedType

    def initialize value
      @value = value
    end

    def to_s
      type
    end

  end
end