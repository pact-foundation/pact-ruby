require 'pact/matchers/base_difference'

module Pact
  module Matchers
    class TypeDifference < BaseDifference

      def as_json options = {}
        if KeyNotFound === actual
          {:EXPECTED_TYPE => expected.as_json, :ACTUAL => actual.as_json }
        else
          {:EXPECTED_TYPE => expected.as_json, :ACTUAL_TYPE => actual.as_json }
        end
      end
    end
  end
end