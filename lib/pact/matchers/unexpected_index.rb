module Pact
  class UnexpectedIndex

    def == other
      other.is_a? UnexpectedIndex
    end

    def to_s
      '<index not to exist>'
    end

    def as_json options = {}
      to_s
    end

    def to_json opts = {}
      as_json.to_json options
    end

  end
end