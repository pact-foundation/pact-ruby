require 'randexp'

module Pact
  module Consumption
    module GenerateResponse

      def self.from_specification(value)
        case
        when value.is_a?(Hash)
          value.inject({}) do |mem, (key,value)|
            mem[key] = from_specification(value)
            mem
          end
        when value.is_a?(Array)
          value.inject([]) do |mem, value|
            mem << from_specification(value)
            mem
          end
        else
          value.is_a?(Regexp) ? value.generate : value
        end
      end

    end
  end
end
