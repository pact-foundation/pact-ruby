module Pact

  def self.consumer_world
    @consumer_world ||= Pact::Consumer::World.new
  end

  # internal api, for testing only
  def self.clear_consumer_world
    @consumer_world = nil
  end

  module Consumer
    class World

      def consumer_contract_builders
        @consumer_contract_builders ||= []
      end

      def add_consumer_contract_builder consumer_contract_builder
        consumer_contract_builders << consumer_contract_builder
      end

    end
  end
end