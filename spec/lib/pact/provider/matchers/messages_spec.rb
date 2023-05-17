require 'spec_helper'
require 'pact/provider/matchers/messages'

module Pact
  module Matchers
    describe Messages do

      include Messages

      describe "#match_term_failure_message" do

        let(:diff_formatter) { Pact::Matchers::UnixDiffFormatter }
        let(:message) { "line1\nline2"}
        let(:output_message) { "Actual: actual\n\n#{message}"}
        let(:output_message_with_resets) { "Actual: \e[37mactual\e[0m\n\n#{r}line1\n#{r}line2"}
        let(:r) { ::Term::ANSIColor.reset }
        let(:diff) { double("diff") }
        let(:actual) { "actual" }
        let(:color_enabled) { true }
        let(:ansi_reset_at_start_of_line) { /^#{Regexp.escape ::Term::ANSIColor.reset}/ }
        let(:message_line_count) { message.split("\n").size }

        before do
          allow(diff_formatter).to receive(:call).and_return(message)
        end

        subject { match_term_failure_message diff, actual, diff_formatter, color_enabled }

        it "creates a message using the diff_formatter" do
          expect(diff_formatter).to receive(:call).with(diff)
          subject
        end

        context "when color_enabled is true" do

          it "returns the message with ANSI reset at the start of each line" do
            expect(subject).to eq(output_message_with_resets)
          end

        end

        context "when the actual is not a string" do

          let(:actual) { { the: "actual" } }

          it "includes the actual as json" do
            expect(subject).to include(actual.to_json)
          end
        end

        context "when color_enabled is false" do

          let(:color_enabled) { false }

          it "returns the message unmodified" do
            expect(subject).to eq(output_message)
          end

        end

      end

      describe "#match_header_failure_message" do

        let(:header_name) { "Content-Type" }
        let(:expected) { "application/json" }
        let(:actual) { "text/plain" }

        subject { match_header_failure_message header_name, expected, actual }
        let(:description_for_it) { expected_desc_for_it(expected) }

        context "when the expected value is a string" do

          let(:expected_message) { "Expected header \"Content-Type\" to equal \"application/json\", but was \"text/plain\"" }

          it "creates a message" do
            expect(subject).to eq(expected_message)
          end

          it "has a description for the it block" do
            expect(description_for_it).to eq "equals \"application/json\""
          end
        end

        context "when the actual is nil" do
          let(:actual) { nil }
          let(:expected_message) { "Expected header \"Content-Type\" to equal \"application/json\", but was nil" }

          it "creates a message" do
            expect(subject).to eq(expected_message)
          end
        end

        context "when the expected is nil" do
          let(:expected) { nil }
          let(:expected_message) { "Expected header \"Content-Type\" to be nil, but was \"text/plain\"" }

          it "creates a message" do
            expect(subject).to eq(expected_message)
          end

          it "has a description for the it block" do
            expect(description_for_it).to eq "is nil"
          end
        end

        context "when the expected is a regexp" do
          let(:expected) { /hal/ }
          let(:expected_message) { "Expected header \"Content-Type\" to match /hal/, but was \"text/plain\"" }

          it "creates a message with the regexp" do
            expect(subject).to eq(expected_message)
          end

          it "has a description for the it block" do
            expect(description_for_it).to eq "matches /hal/"
          end
        end

        context "when the expected is a Term" do
          let(:expected) { Pact.term("application/hal+json", /hal/) }
          let(:expected_message) { "Expected header \"Content-Type\" to match /hal/, but was \"text/plain\"" }

          it "creates a message with the term's matcher" do
            expect(subject).to eq(expected_message)
          end

          it "has a description for the it block" do
            expect(description_for_it).to eq "matches /hal/"
          end
        end

        context "when the expected is a SomethingLike" do
          let(:actual) { nil }
          let(:expected) { Pact.like("foo") }
          let(:expected_message) { "Expected header \"Content-Type\" to be an instance of String, but was nil" }

          it "creates a message with the expected class" do
            expect(subject).to eq(expected_message)
          end

          it "has a description for the it block" do
            expect(description_for_it).to eq "is an instance of String"
          end
        end
      end
    end
  end
end
