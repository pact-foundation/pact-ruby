require 'spec_helper'
require 'pact/shared/request'

module Pact

  module Request

    describe Base do

      class TestRequest < Base

        def self.key_not_found
          nil
        end

      end

      subject { TestRequest.new("get", "/", {some: "things"}, {some: "things"} , "some=things") }

      describe "#to_json" do
        it "renders the keys in a sensible order" do
          expect(subject.to_json).to match(/method.*path.*query.*headers.*body/)
        end
      end

    end
  end
end