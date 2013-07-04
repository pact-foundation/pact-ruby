module Pact
  module Producer
    class InteractionFixture

      attr_accessor :name

      def self.interaction_fixture name, &block
        InteractionFixture.new(name, &block)
      end

      def self.register name, interaction_fixture
        interaction_fixtures[name.to_sym] = interaction_fixture
      end

      def self.interaction_fixtures
        @@interaction_fixtures ||= {}
      end

      def self.get name
        interaction_fixtures[name.to_sym]
      end

      def register
        self.class.register(name, self)
      end

      def initialize name, &block
        @name = name
        instance_eval(&block)
      end

      def set_up &block
        if block_given?
          @set_up_block = block
        elsif @set_up_block
          instance_eval &@set_up_block
        end
      end

      def tear_down &block
        if block_given?
          @tear_down_block = block
        elsif @tear_down_block
          instance_eval &@tear_down_block
        end
      end
    end
  end
end

#Argh, global method, how can I fix this so it's still available without namespaceing?
def interaction_fixture name, &block
  Pact::Producer::InteractionFixture.interaction_fixture(name, &block).register
end
