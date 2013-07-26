require 'spec_helper'
require 'pact/configuration'

module Pact
  describe "configure" do
    KEY_VALUE_PAIRS = {pact_dir: 'a path', log_dir: 'a dir'}

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
    before do
      Pact.class_variable_set('@@configuration', nil)
    end

    it "should have a default pact_dir" do
      expect(Pact.configuration.pact_dir).to eql File.expand_path('./spec/pacts')
    end
    it "should have a default log_dir" do
      expect(Pact.configuration.log_dir).to eql File.expand_path('./log')
    end
  end
end