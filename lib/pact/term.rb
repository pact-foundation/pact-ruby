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

    # TODO: this is pretty nasty - need to find a better solution
    def ==(other)
      !!(match =~ other)
    end

  end
end
