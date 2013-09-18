module Pact
  class UnexpectedIndex

    def == other
      other.is_a? UnexpectedIndex
    end

    def to_s
      '<index not to exist>'
    end

    def to_json opts = {}
      to_s
    end

  end
end