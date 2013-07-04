module Pact
  module Producer
    class ProducerState

      attr_accessor :name

      def self.producer_state name, &block
        ProducerState.new(name, &block)
      end

      def self.register name, producer_state
        producer_states[name.to_sym] = producer_state
      end

      def self.producer_states
        @@producer_states ||= {}
      end

      def self.get name
        producer_states[name.to_sym]
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
def producer_state name, &block
  Pact::Producer::ProducerState.producer_state(name, &block).register
end
