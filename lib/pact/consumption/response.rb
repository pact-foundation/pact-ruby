require 'randexp'

module Pact
  module Consumption
    class Response

      attr_reader :specification

      def initialize specification
        @specification = specification
      end

      def reify
        reify_specification(@specification)
      end

      def to_json
        @specification
      end

      private

      def reify_specification(specification)
        case
        when specification.is_a?(Hash)
          specification.inject({}) do |mem, (key,value)|
            mem[key] = reify_specification(value)
            mem
          end
        when specification.is_a?(Array)
          specification.inject([]) do |mem, value|
            mem << reify_specification(value)
            mem
          end
        else
          template(specification)
        end
      end

      def template(value)
        value.is_a?(Regexp) ? value.generate : value
      end

    end
  end
end
