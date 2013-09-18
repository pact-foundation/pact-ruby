require 'spec_helper'
require 'support/shared_examples_for_request'

module Pact
  describe Consumer::Request::Actual do
    it_behaves_like "a request"

    let(:raw_request) do
      {
        'method' => 'get',
        'path' => '/mallory'
      }
    end

    describe "from_hash" do
      context "when field are not defined" do
        subject { described_class.from_hash(raw_request) }
        it "raises an error" do
          expect{subject}.to raise_error KeyError
        end
      end
    end      
  end
end
