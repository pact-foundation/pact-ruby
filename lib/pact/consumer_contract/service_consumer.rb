module Pact
  class ServiceConsumer
    attr_accessor :name
    def initialize options
      @name = options[:name]
    end

    def to_s
      name
    end

    def as_json options = {}
      {name: name}
    end

    def self.from_hash obj
      ServiceConsumer.new(:name => obj['name'])
    end
  end
end