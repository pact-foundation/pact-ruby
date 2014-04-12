require 'spec_helper'
require 'pact/shared/active_support_support'

module Pact
  describe ActiveSupportSupport do

    include ActiveSupportSupport


    describe "fix_regexp" do
      let(:regexp) { /moose/ }

      subject { fix_regexp regexp }

      it "returns the original regexp" do
        expect(subject).to be(regexp)
      end

      it "fixes the as_json method for Regexp that ActiveSupport tramples beneath its destructive hooves of destruction" do
        expect(subject.to_json).to eq("{\"json_class\":\"Regexp\",\"o\":0,\"s\":\"moose\"}")
      end
    end

    describe "fix_all_the_things" do
      let(:hash) do
        { 'body' => Pact::Term.new(matcher: /a*b/, generate: 'abba'), array: [/blah/], thing: /alligator/ }
      end

      subject { fix_all_the_things(hash) }

      it "returns the original object" do
        expect(subject).to be(hash)
      end

      it "finds all the Regexp objects in hashes or Pact class attributes and fixes the as_json method" do
        json = subject.to_json
        expect(json).to include("{\"json_class\":\"Regexp\",\"o\":0,\"s\":\"a*b\"}")
        expect(json).to include("{\"json_class\":\"Regexp\",\"o\":0,\"s\":\"blah\"}")
        expect(json).to include("{\"json_class\":\"Regexp\",\"o\":0,\"s\":\"alligator\"}")
      end
    end

    describe "fix_json_formatting" do
      let(:active_support_affected_pretty_generated_json) { "{\"json_class\":\"Regexp\",\"o\":0,\"s\":\"a*b\"}" }
      let(:pretty_generated_json) do
'{
  "json_class": "Regexp",
  "o": 0,
  "s": "a*b"
}'
      end

      it "pretty formats the json that has been not pretty formatted because of ActiveSupport" do
        expect(fix_json_formatting(active_support_affected_pretty_generated_json)).to eq (pretty_generated_json.strip)
      end
    end
  end
end