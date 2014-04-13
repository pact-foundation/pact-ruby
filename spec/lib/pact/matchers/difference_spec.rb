require 'spec_helper'
require 'pact/matchers/difference'

module Pact
  module Matchers
    describe Difference do

      describe "#as_json" do

        context "when something other than a regexp is expected" do

          subject { Difference.new("apple", 'pear').as_json }

          it "indicates that the actual was intended 'to eq'" do
            expect(subject).to eq({:EXPECTED => "apple", :ACTUAL => "pear"})
          end
        end

      end
    end
  end
end