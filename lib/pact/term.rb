module Pact
  class Term

    attr_reader :generate, :match

    def initialize(options = {})
      @generate = options[:generate]
      @match = options[:match]
    end

  end
end
