module Pact
  class UnexpectedKey

    def == other
      other.is_a? UnexpectedKey
    end
     

    def to_s
      '<key not to exist>'
    end

    def to_json opts = {}
      to_s
    end
  end
end