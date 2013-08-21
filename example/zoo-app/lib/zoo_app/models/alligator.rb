module ZooApp
  module Animals
    class Alligator
      attr_reader :name
      def initialize attributes
        @name = attributes[:name]
      end

      def == other
        other.is_a?(Alligator) && other.name == self.name
      end

    end
  end
end