require 'spec_helper'
require 'pact/consumer_contract/headers'

module Pact
  describe Headers do

    describe "initialize" do

      context "with duplicate headers" do

        subject { Headers.new('Content-Type' => 'application/hippo', 'CONTENT-TYPE' => 'application/giraffe') }

        it "raises an error" do
          expect { subject }.to raise_error DuplicateHeaderError, /Content\-Type.*CONTENT\-TYPE/
        end

      end

      context "with a symbol as a header name" do

        subject { Headers.new(:'content-type' => 'application/hippo') }

        it "converts the header name to a String" do
          expect( subject.to_hash ).to eq 'content-type' => 'application/hippo'
        end

      end

      context "with a nil header name" do

        subject { Headers.new(nil => 'application/hippo') }

        it "raises an error" do
          expect{ subject }.to raise_error InvalidHeaderNameTypeError
        end

      end

      context "with a boolean header name" do

        subject { Headers.new(false => 'application/hippo') }

        it "raises an error" do
          expect{ subject }.to raise_error InvalidHeaderNameTypeError
        end

      end

    end

    describe "[]" do

      subject { Headers.new 'Content-Type' => 'application/hippo' }

      it "is case insensitive as HTTP headers are case insensitive" do
        expect(subject['Content-Type']).to eq('application/hippo')
        expect(subject['CONTENT-TYPE']).to eq('application/hippo')
        expect(subject['content-type']).to eq('application/hippo')
      end

    end

    describe "fetch" do

      subject { Headers.new 'Content-Type' => 'application/hippo' }

      it "is case insensitive as HTTP headers are case insensitive" do
        expect(subject.fetch('Content-Type')).to eq('application/hippo')
        expect(subject.fetch('CONTENT-TYPE')).to eq('application/hippo')
        expect(subject.fetch('content-type')).to eq('application/hippo')
        expect(subject.fetch('Content-Length','1')).to eq('1')
        expect { subject.fetch('Content-Length')}.to raise_error KeyError
      end

    end

    describe "key?" do

      subject { Headers.new 'Content-Type' => 'application/hippo' }

      it "is case insensitive as HTTP headers are case insensitive" do
        expect(subject.key?('CONTENT-TYPE')).to be true
        expect(subject.key?('CONTENT-LENGTH')).to be false
      end
    end

    describe "has_key?" do

      subject { Headers.new 'Content-Type' => 'application/hippo' }

      it "is case insensitive as HTTP headers are case insensitive" do
        expect(subject.has_key?('CONTENT-TYPE')).to be true
        expect(subject.has_key?('CONTENT-LENGTH')).to be false
      end
    end

    describe "[]=" do

      subject { Headers.new }

      it "does not allow modification" do
        expect{ subject['Content-Type'] = 'application/hippo' }.to raise_error /frozen/
      end

    end
  end
end