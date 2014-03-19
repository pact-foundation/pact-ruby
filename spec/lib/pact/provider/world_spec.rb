require 'spec_helper'
require 'pact/provider/world'

describe Pact do
  describe ".world" do
    it "returns a world" do
      expect(Pact.world).to be_instance_of Pact::Provider::World
    end
    it "returns the same world each time" do
      expect(Pact.world).to be Pact.world
    end
  end

  describe ".clear_world" do
    it "clears the world" do
      original_world = Pact.world
      Pact.clear_world
      expect(original_world).to_not be Pact.world
    end
  end

end

module Pact
  module Provider
    describe World do

      subject { World.new }
      describe "provider_states" do
        it "returns a provider state proxy" do
          expect(subject.provider_states).to be_instance_of State::ProviderStateProxy
        end
        it "returns the same object each time" do
          expect(subject.provider_states).to be subject.provider_states
        end

      end

    end
  end
end
