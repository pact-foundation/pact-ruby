module Pact
  module Matchers
    class Combined
      VALID_COMBINATIONS = %i[and or].freeze

      attr_reader :matchers, :combine, :template

      def initialize(matchers, combine:, template:)
        raise ArgumentError, "At least two matchers are required" if matchers.size < 2

        unless matchers.all?(Pact::Matchers::Base)
          raise ArgumentError, "All values must be Pact matchers"
        end

        unless VALID_COMBINATIONS.include?(combine)
          raise ArgumentError, "combine must be :and or :or"
        end

        @matchers = matchers
        @combine = combine
        @template = template
      end

      def as_matching_rule
        {
          "combine" => combine.to_s.upcase,
          "matchers" => matchers.map(&:as_matching_rule)
        }
      end
    end
  end
end 