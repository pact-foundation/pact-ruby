module Pact
  class Term

    attr_reader :generate, :match

    def initialize(options = {})
      @generate = options[:generate]
      @match = options[:match]
    end

    def self.json_create(obj)
      new(generate: obj['data']['generate'], match: obj['data']['match'])
    end

    def to_json(options = {})
      { json_class: self.class.name, data: { generate: generate, match: match} }.to_json(options)
    end

    def matches?(literal)
      !!(match =~ literal)
    end

  end
end
