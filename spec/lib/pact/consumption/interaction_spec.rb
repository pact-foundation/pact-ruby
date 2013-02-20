require 'spec_helper'

module Pact
  module Consumption
    describe Interaction do

      subject { Interaction.new(request) }

      let(:request) { { key: 'value' } }

      describe "setting up response specifications" do

        let(:response_spec) { { key: /pattern/ } }

        it "creates a response with the provided specification" do
          subject.will_respond_with response_spec
          expect(subject.response).to have_specification response_spec
        end
      end

    end
  end
end
