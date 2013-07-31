require 'spec_helper'
require 'pact/configuration'

describe Pact do

  before do
    Pact.clear_configuration
  end

  describe "configure" do
    KEY_VALUE_PAIRS = {pact_dir: 'a path', log_dir: 'a dir', logger: 'a logger'}

    KEY_VALUE_PAIRS.each do | key, value |
      it "should allow configuration of #{key}" do
        Pact.configure do | config |
          config.send("#{key}=".to_sym, value)
        end

        expect(Pact.configuration.send(key)).to eql(value)
      end
    end
  end

  describe "configuration" do
    it "should have a default pact_dir" do
      expect(Pact.configuration.pact_dir).to eql File.expand_path('./spec/pacts')
    end
    it "should have a default log_dir" do
      expect(Pact.configuration.log_dir).to eql File.expand_path('./log')
    end
    it "should have a default logger configured" do
      expect(Pact.configuration.logger).to be_instance_of Logger
    end
  end
end