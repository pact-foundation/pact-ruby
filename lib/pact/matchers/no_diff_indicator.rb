module Pact
  module Matchers
    class NoDiffIndicator

      def to_json options = {}
        to_s
      end

      def to_s
        'no difference here!'
      end

      def == other
        other.is_a? NoDiffIndicator
      end
    end
  end
end