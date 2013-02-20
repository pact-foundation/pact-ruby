require 'randexp'

module Pact
  module Consumption
    class Response

      def initialize spec
        @spec = spec
      end

      def reify
        reify_spec(@spec)
      end

      private

      def reify_spec(spec)
        case
        when spec.is_a?(Hash)
          spec.inject({}) do |mem, (key,value)|
            mem[key] = reify_spec(value)
          mem
          end
        when spec.is_a?(Array)
          spec.inject([]) do |mem, value|
            mem << reify_spec(value)
            mem
          end
        else
          template(spec)
        end
      end

      def template(value)
        value.is_a?(Regexp) ? value.generate : value
      end

    end
  end
end
