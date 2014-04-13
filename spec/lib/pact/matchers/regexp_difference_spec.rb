require 'spec_helper'
require 'pact/matchers/regexp_difference'

module Pact
  module Matchers
    describe RegexpDifference do

      context "when a regexp is expected" do

        subject { RegexpDifference.new(/ap/, 'pear').as_json }

        it "indicates that the actual was indended 'to match'" do
          expect(subject).to eq({:EXPECTED_TO_MATCH => "/ap/", :ACTUAL => "pear"})
        end

      end

    end
  end
end