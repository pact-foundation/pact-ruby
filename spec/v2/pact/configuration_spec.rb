# frozen_string_literal: true

RSpec.describe Pact::V2::Configuration do
  subject(:config) { described_class.new }

  describe "#before_provider_state_setup" do
    it "raises if block is not given" do
      expect { config.before_provider_state_setup }.to raise_error(/no block given/)
    end

    it "configures setup block" do
      config.before_provider_state_setup {}
      expect(config.before_provider_state_proc).to be_instance_of(Proc)
    end
  end

  describe "#after_provider_state_teardown" do
    it "raises if block is not given" do
      expect { config.after_provider_state_teardown }.to raise_error(/no block given/)
    end

    it "configures teardown block" do
      config.after_provider_state_teardown {}
      expect(config.after_provider_state_proc).to be_instance_of(Proc)
    end
  end
end
