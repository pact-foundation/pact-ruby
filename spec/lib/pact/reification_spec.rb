require 'spec_helper'

module Pact
  describe Reification do

    let(:response_spec) do
      {
        woot: /x/,
        britney: 'britney',
        nested: { foo: /bar/, baz: 'qux' },
        my_term: Term.new(generate: 'wiffle', matcher: /^wif/),
        array: ['first', /second/]
      }
    end

    describe "from term" do

      subject { Reification.from_term(response_spec) }

      it "converts regexes into real data" do
        expect(subject[:woot]).to eql 'x'
      end

      it "converts terms into real data" do
        expect(subject[:my_term]).to eql 'wiffle'
      end

      it "passes strings through" do
        expect(subject[:britney]).to eql 'britney'
      end

      it "handles nested hashes" do
        expect(subject[:nested]).to eql({ foo: 'bar', baz: 'qux' })
      end

      it "handles arrays" do
        expect(subject[:array]).to eql ['first', 'second']
      end

    end

    context "when reifying a Request" do

      let(:request){ Pact::Request::Expected.from_hash(method: 'get', path: '/', body: Pact::Term.new(generate: "sunny", matcher: /sun/))}

      subject { Reification.from_term(request) }

      it "turns it into a hash before reifying it" do
        expect(subject[:body]).to eq("sunny")
      end

    end

    context "when SomethingLike" do

      let(:request) { Pact::SomethingLike.new({a: 'String'})}

      subject { Reification.from_term(request)}

      it "returns the contents of the SomethingLike" do
        expect(subject).to eq({a: 'String'})
      end

    end

  end
end
