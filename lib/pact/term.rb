module Pact
  class Term

    attr_reader :generate, :matcher

    def self.json_create(obj)
      new(generate: obj['data']['generate'], matcher: obj['data']['matcher'])
    end

    def initialize(options = {})
      @generate = options[:generate]
      @matcher = options[:matcher]
    end

    def to_json(options = {})
      { json_class: self.class.name, data: { generate: generate, matcher: matcher} }.to_json(options)
    end

    def matches?(literal)
      !!(matcher =~ literal)
    end

    def ==(other)
      generate == other.generate && matcher == other.matcher
    end

  end
end
