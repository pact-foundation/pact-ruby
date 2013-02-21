require 'spec_helper'

module Pact
  module Consumption
    describe Consumer do

      subject { Consumer.new('Consumer') }

      it "creates a MockProducer for an assumption" do
        expect(subject.assumes_a_service('Service')).to be_a MockProducer
      end

    end
  end
end
