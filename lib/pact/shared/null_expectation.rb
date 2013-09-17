module Pact
  class NullExpectation
    def to_s
      "<No expectation>"
    end

    def ==(other_object)
     other_object.is_a? NullExpectation
    end

    def ===(other_object)
     other_object.is_a? NullExpectation
    end

    def eql?(other_object)
      self == other_object
    end

    def hash
      2934820948209428748274238642672
    end

    def empty?
      true
    end

    def nil?
      true
    end
  end
end