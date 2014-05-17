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

    end
  end
end