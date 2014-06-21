require 'pact/matchers/matchers'

module Pact
  class TextDiffer

    extend Matchers


    def self.call expected, actual, options = {}
      diff expected, actual, options
    end


  end
end
