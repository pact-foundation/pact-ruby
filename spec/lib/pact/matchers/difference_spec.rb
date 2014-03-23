require 'spec_helper'
require 'pact/matchers/difference'

module Pact
  module Matchers
    describe Difference do

      describe "#to_hash" do

        context "when a regexp is expected" do

          subject { Difference.new(/ap/, 'pear').to_hash }

          it "indicates that the actual was indended 'to match'" do
            expect(subject).to eq({:EXPECTED_TO_MATCH => "/ap/", :ACTUAL => "pear"})
          end

        end

        context "when something other than a regexp is expected" do

          subject { Difference.new("apple", 'pear').to_hash }

          it "indicates that the actual was intended 'to eq'" do
            expect(subject).to eq({:EXPECTED => "apple", :ACTUAL => "pear"})
          end
        end

      end
    end
  end
end