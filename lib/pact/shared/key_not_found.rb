require 'pact/matchers/difference_indicator'

module Pact
  class KeyNotFound < Pact::DifferenceIndicator

    def to_s
      "<key not found>"
    end

    def empty?
      true
    end
  end

end