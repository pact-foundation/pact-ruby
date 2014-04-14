require 'spec_helper'
require 'pact/provider/matchers/messages'

module Pact
  module Matchers
    describe Messages do

      include Messages

      describe "#match_term_failure_message" do

        let(:message) { "line1\nline2"}
        let(:r) { ::Term::ANSIColor.reset }
        let(:message_with_resets) { "#{r}line1\n#{r}line2"}
        let(:diff) { double("diff") }
        let(:color_enabled) { true }
        let(:ansi_reset_at_start_of_line) { /^#{Regexp.escape ::Term::ANSIColor.reset}/ }
        let(:message_line_count) { message.split("\n").size }

        before do
          allow(Pact.configuration.diff_formatter).to receive(:call).and_return(message)
        end

        subject { match_term_failure_message diff, color_enabled }

        it "creates a message using the configured diff_formatter" do
          expect(Pact.configuration.diff_formatter).to receive(:call).with(diff)
          subject
        end

        context "when color_enabled is true" do

          it "returns the message with ANSI reset at the start of each line" do
            expect(subject).to eq(message_with_resets)
          end

        end

        context "when color_enabled is false" do

          let(:color_enabled) { false }

          it "returns the message unmodified" do
            expect(subject).to eq(message)
          end

        end

      end

      describe "#match_header_failure_message" do

        let(:header_name) { "Content-Type" }
        let(:expected) { "application/json" }
        let(:actual) { "text/plain" }

        subject { match_header_failure_message header_name, expected, actual }

        context "when the expected value is a string" do

          let(:expected_message) { "Expected header \"Content-Type\" to match \"application/json\", but was \"text/plain\"" }

          it "creates a message" do
            expect(subject).to eq(expected_message)
          end

        end

        context "when the actual is nil" do

          let(:actual) { nil }
          let(:expected_message) { "Expected header \"Content-Type\" to match \"application/json\", but was nil" }

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

        end

        context "when the expected is a Pact::Term" do

          let(:expected) { Pact::Term.new(matcher: /hal/, generate: 'application/hal+json')}
          let(:expected_message) { "Expected header \"Content-Type\" to match /hal/, but was \"text/plain\"" }

          it "creates a message with the term's matcher" do
            expect(subject).to eq(expected_message)
          end

        end
      end
    end
  end
end