module Pact
  class UnexpectedKey

    def == other
      other.is_a? UnexpectedKey
    end

    def to_s
      '<key not to exist>'
    end

    def as_json options = {}
      to_s
    end

    def to_json opts = {}
      to_s
    end
  end
end