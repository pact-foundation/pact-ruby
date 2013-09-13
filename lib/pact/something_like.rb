module Pact

  class SomethingLike
    attr_reader :contents

    def initialize contents
      @contents = contents
    end

    def as_json
      {
        :json_class => self.class.name,
        :contents => contents
      }
    end

    def to_json opts = {}
      as_json.to_json opts
    end

    def self.json_create hash
      new(hash['contents'])
    end

    def generate
      contents
    end
  end
end


