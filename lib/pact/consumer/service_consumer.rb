module Pact
  module Consumer
    class ServiceConsumer
      attr_accessor :name
      def initialize options
        @name = options[:name]
      end

      def to_s
        name
      end
    end
  end
end