require 'spec_helper'
require 'pact/provider/test_methods'

module Pact::Provider
  describe TestMethods do

    class TestHelper
      include TestMethods
    end

    subject { TestHelper.new }

    describe "get_provider_state" do
      it "raises a descriptive error if the provider state is not found" do
        ProviderState.stub(:get).and_return(nil)
        expect{ subject.send(:get_provider_state, 'some state', 'consumer') }.to raise_error /Could not find.*some state.*consumer.*/
      end
    end
  end
end