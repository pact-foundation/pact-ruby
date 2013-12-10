require 'spec_helper'
require 'pact/matchers/diff_decorator'
require 'pact/matchers/matchers'

module Pact
  module Matchers
    describe DiffDecorator do

      describe "to_s" do
        subject { DiffDecorator.new(diff) }

        context "when there is a mismatched key value" do
          let(:diff) { {body: {"blah" => { "thing" => Difference.new("alphabet", "woozle")}}} }

          it "includes the expected value" do
            expect(subject.to_s).to match(/Expected key "thing":.*"alphabet"/m)
          end
          it "includes the actual value" do
            expect(subject.to_s).to match(/Actual:.*"woozle"/m)
          end

          it "includes the path" do
            expect(subject.to_s).to include('[:root]["blah"]')
          end
        end

        context "when there is a mismatched index value" do
          let(:diff) { {body: {"blah" => [ Difference.new("wiffile", "badger")] } } }

          it "includes the expected value" do
            expect(subject.to_s).to match(/Expected key "thing":.*"alphabet"/m)
          end
          it "includes the actual value" do
            expect(subject.to_s).to match(/Actual:.*"woozle"/m)
          end

          it "includes the path" do
            expect(subject.to_s).to include('[:root]["blah"]')
          end
        end

        context "when there is a mismatched nested value" do
          let(:diff) { {body: {"blah" => [ {"thing" => Difference.new("wiffile", "badger")}] } } }

          it "includes the expected value" do
            expect(subject.to_s).to match(/Expected key "thing":.*"alphabet"/m)
          end
          it "includes the actual value" do
            expect(subject.to_s).to match(/Actual:.*"woozle"/m)
          end

          it "includes the path" do
            expect(subject.to_s).to include('[:body]["blah"][1]')
          end
        end

        context "when there is a missing key" do
          let(:expected_hash) { {"abc" => {"def" => [1,2]}}}
          let(:diff) { {body: {"blah" => { "thing" => Difference.new(expected_hash, Pact::KeyNotFound.new )}}} }
          let(:expected_output) { ""}

          it "includes the expected value" do
            expect(subject.to_s).to match(/Missing key with value\:.*\{/m)
          end

          it "includes the path" do
            expect(subject.to_s).to include('[:root]["blah"][1]')
          end
        end

        context "when there is a missing index" do
          let(:diff) { {:body => {"some_array" => [NoDiffIndicator.new, Difference.new({"wiffle" => "woot"}, IndexNotFound.new )]}} }
          it "includes the expected value" do
            expect(subject.to_s).to match(/Missing.*1/m)
          end

          it "includes the path" do
            expect(subject.to_s).to include('[1]')
          end
        end

        context "when there is an unexpected index" do
          let(:diff) { {:body => {"some_array" => [NoDiffIndicator.new, Difference.new(UnexpectedIndex.new, {"blah" => "meep"}), Difference.new(UnexpectedIndex.new, "b")]}}}
          it "includes the unexpected value" do
            expect(subject.to_s).to include("Array contained unexpected item:")
          end

          it "includes the path" do
            expect(subject.to_s).to include('[1]')
            expect(subject.to_s).to include('[2]')
          end
        end

        context "when there is an unexpected key" do
          let(:diff) { {body: {"blah" => Difference.new(UnexpectedKey.new, "surprise!")}} }
          it "includes the unexpected key" do
            expect(subject.to_s).to include("Hash contained unexpected key with value:")
          end

          it "includes the path" do
            expect(subject.to_s).to include('["blah"]')
          end
        end

      end

    end
  end
end