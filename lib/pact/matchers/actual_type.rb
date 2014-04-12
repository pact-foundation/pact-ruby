require 'pact/matchers/expected_type'


module Pact
  class ActualType < Pact::ExpectedType

    def initialize value
      @value = value
    end

    def to_s
      "actual: #{type} value: #{@value}"
    end

  end
end