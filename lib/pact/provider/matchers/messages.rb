require 'term/ansicolor'
require 'pact/term'

module Pact
  module Matchers
    module Messages

      def match_term_failure_message diff, color_enabled
        message = Pact.configuration.diff_formatter.call(diff)

        if color_enabled
          # RSpec wraps each line in the failure message with failure_color, turning it red.
          # To ensure the lines in the diff that should be white, stay white, put an
          # ANSI reset at the start of each line.
          message.split("\n").collect{ |line| ::Term::ANSIColor.reset + line }.join("\n")
        else
          message
        end

      end

      def match_header_failure_message header_name, expected, actual
        "Expected header \"#{header_name}\" to #{expected_desc(expected)}, but was #{actual_desc(actual)}"
      end

      private

      def expected_desc expected
        case expected
        when Pact::Term then "match #{expected.matcher.inspect}"
        when NilClass then "be nil"
        else
          "match \"#{expected}\""
        end
      end

      def actual_desc actual
        actual.nil? ? 'nil' : '"' + actual + '"'
      end

    end
  end
end