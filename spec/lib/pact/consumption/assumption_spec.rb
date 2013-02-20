require 'spec_helper'

module Pact
  module Consumption
    describe Assumption do

      subject { Assumption.new(services) }

      let(:service) { MockProducer.new('http://example.com') }
      let(:another_service) { MockProducer.new('http://example.com') }

      let(:services) { { service_one: service, service_two: another_service } }

      it "provides access to services by name" do
        expect(subject.service(:service_one)).to eql service
      end

    end
  end
end
