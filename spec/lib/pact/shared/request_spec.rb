require 'spec_helper'
require 'pact/shared/request'
require 'pact/shared/key_not_found'

module Pact

  module Request

    describe Base do

      class TestRequest < Base

        def self.key_not_found
          Pact::KeyNotFound.new
        end

      end

      subject { TestRequest.new("get", "/", {some: "things"}, {some: "things"} , "some=things") }

      describe "#to_json" do
        it "renders the keys in a sensible order" do
          expect(subject.to_json).to match(/method.*path.*query.*headers.*body/)
        end
      end

      describe "#full_path" do

        subject { TestRequest.new("get", "/something", {}, {some: "things"} , query).full_path }

        context "with a query that is a Pact::Term" do
          let(:query) { Pact::Term.new(generate: "some=things", matcher: /some/) }
          it "reifies and appends the query" do
            expect(subject).to eq("/something?some=things")
          end
        end

        context "with a query that is a string" do
          let(:query) { "some=things" }
          it "appends the query" do
            expect(subject).to eq("/something?some=things")
          end
        end

        context "with an empty query" do
          let(:query) { "" }
          it "does include a query" do
            expect(subject).to eq("/something")
          end
        end

        context "with a nil query" do
          let(:query) { nil }
          it "does not include a query" do
            expect(subject).to eq("/something")
          end
        end
      end

      describe "#method_and_path" do
        context "with an empty path" do
          subject { TestRequest.new("get", "", {}, {} , "").method_and_path }

          it "includes a slash" do
            expect(subject).to eq("GET /")
          end
        end

        context "with a path" do
          subject { TestRequest.new("get", "/something", {}, {} , "").method_and_path }

          it "includes the path" do
            expect(subject).to eq("GET /something")
          end
        end

        context "with a query" do
          subject { TestRequest.new("get", "/something", {}, {} , "test=query").method_and_path }

          it "includes the query" do
            expect(subject).to eq("GET /something?test=query")
          end
        end
      end

      describe "#content_type" do

        subject { TestRequest.new("get", "/something", headers, {} , "") }
        context "when there are no expected headers" do
          let(:headers) { Pact::KeyNotFound.new }
          it "returns nil" do
            expect(subject.send(:content_type)).to be nil
          end
        end
        context "when there is no Content-Type header" do
          let(:headers) { {} }
          it "returns the content-type" do
            expect(subject.send(:content_type)).to be nil
          end
        end
        context "when there is a content-type header (" do
          let(:headers) { {'content-type' => 'blah'} }
          it "returns the content-type" do
            expect(subject.send(:content_type)).to eq 'blah'
          end
        end
      end

    end
  end
end