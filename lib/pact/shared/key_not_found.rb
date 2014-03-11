module Pact
  class KeyNotFound
    def == other
      other.is_a? KeyNotFound
    end

    def eql? other
      self == other
    end

    def to_s
      "<key not found>"
    end

    def as_json options={}
      to_s
    end

    def to_json options = {}
      to_s
    end

    def empty?
      true
    end
  end

end