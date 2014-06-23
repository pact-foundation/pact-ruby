require 'pact/matchers/matchers'
require 'pact/matchers/difference'

module Pact
  class TextDiffer

    extend Matchers

    def self.call expected, actual, options = {}
      diff expected, actual, options
    end

  end
end
