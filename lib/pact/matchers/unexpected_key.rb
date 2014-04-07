require 'pact/matchers/difference_indicator'

module Pact
  class UnexpectedKey < Pact::DifferenceIndicator

    def to_s
      '<key not to exist>'
    end

  end
end