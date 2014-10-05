require 'spec_helper'
require 'pact/consumer_contract/response'

module Pact

  describe Response do

    subject { Response.from_hash(status: 200, headers: {'Content-Type' => 'application/json'}, body: {some: 'body'}) }

    describe "#status" do
      it "returns the status" do
        expect(subject.status).to eq 200
      end
    end

    describe "#headers" do
      it "returns the Headers" do
        expect(subject.headers).to eq Headers.new('Content-Type' => 'application/json')
      end
    end

    describe "#body" do
      it "returns the body" do
        expect(subject.body).to eq some: 'body'
      end
    end

    describe "#body_allows_any_value?" do
      context "when the body is not specified" do
        subject { Response.from_hash(status: 200, headers: {'Content-Type' => 'application/json'}) }

        it "returns true" do
          expect(subject.body_allows_any_value?).to be true
        end
      end

      context "when the body is an empty hash" do
        subject { Response.from_hash(status: 200, headers: {'Content-Type' => 'application/json'}, body: {}) }

        it "returns true" do
          expect(subject.body_allows_any_value?).to be true
        end
      end

      context "when the body is an empty string" do
        subject { Response.from_hash(status: 200, headers: {'Content-Type' => 'text/plain'}, body: '') }

        it "returns false" do
          expect(subject.body_allows_any_value?).to be false
        end
      end

      context "when the body is a hash with values" do
        subject { Response.from_hash(status: 200, headers: {'Content-Type' => 'text/plain'}, body: {some: 'body'}) }

        it "returns false" do
          expect(subject.body_allows_any_value?).to be false
        end
      end

      context "when the body is a non-empty String" do
        subject { Response.from_hash(status: 200, headers: {'Content-Type' => 'text/plain'}, body: 'a string') }

        it "returns false" do
          expect(subject.body_allows_any_value?).to be false
        end
      end

    end

  end

end