require 'spec_helper'

module Pact::Consumer
   describe ServiceConsumer do
      describe "as_json" do
         it "returns a hash representation of the object" do
            expect(ServiceConsumer.new(:name => "Bob").as_json).to eq :name => "Bob"
         end
      end
   end
end   