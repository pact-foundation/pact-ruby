require 'spec_helper'

module Pact
  describe SomethingLike do
    describe 'json_create' do
      let(:json) do
'
{
    "json_class": "Pact::SomethingLike",
    "contents" : { "thing" : "blah" }
}
'
      end
      subject { SomethingLike.json_create(JSON.parse(json)) }
      it "creates a SomethingLike object from json" do
        expect(subject).to eq(SomethingLike.new({"thing" => "blah"}))
      end
    end
  end

end