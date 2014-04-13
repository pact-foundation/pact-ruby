require 'pact/matchers/base_difference'

module Pact
  module Matchers
    class RegexpDifference < BaseDifference

      def as_json options = {}
        {:EXPECTED_TO_MATCH => expected.inspect, :ACTUAL => actual}
      end

    end
  end
end