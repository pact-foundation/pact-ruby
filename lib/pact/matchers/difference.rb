module Pact
  module Matchers
    class Difference

      attr_reader :expected, :actual

      def initialize expected, actual
        @expected = expected
        @actual = actual
      end

      def any?
        true
      end

      def empty?
        false
      end

      def to_hash
        if Regexp === expected
          {:EXPECTED_TO_MATCH => expected.inspect, :ACTUAL => actual}
        else
          {:EXPECTED => expected, :ACTUAL => actual}
        end
      end

      def to_json options = {}
        to_hash.to_json(options)
      end

      def to_s
        to_hash.to_s
      end

      def == other
        other.is_a?(Difference) && other.expected == expected && other.actual == actual
      end

    end
  end
end