require 'spec_helper'
require 'pact/configuration'

module Pact
  describe "configure" do
    KEY_VALUE_PAIRS = {pacts_path: 'a path'}

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

    it "should have a default pacts_path" do
      expect(Pact.configuration.pacts_path).to eql File.expand_path('./spec/pacts')
    end
  end
end