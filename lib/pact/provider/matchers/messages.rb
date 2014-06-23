require 'term/ansicolor'
require 'pact/term'

module Pact
  module Matchers
    module Messages

      def match_term_failure_message diff, actual, diff_formatter, color_enabled
        message = "Actual: #{(String === actual ? actual : actual.to_json)}\n\n"
        formatted_diff = diff_formatter.call(diff)
        message + colorize_if_enabled(formatted_diff, color_enabled)
      end

      def match_header_failure_message header_name, expected, actual
        "Expected header \"#{header_name}\" to #{expected_desc(expected)}, but was #{actual_desc(actual)}"
      end

      private

      def colorize_if_enabled formatted_diff, color_enabled
        if color_enabled
          # RSpec wraps each line in the failure message with failure_color, turning it red.
          # To ensure the lines in the diff that should be white, stay white, put an
          # ANSI reset at the start of each line.
          formatted_diff.split("\n").collect{ |line| ::Term::ANSIColor.reset + line }.join("\n")
        else
          formatted_diff
        end
      end

      def expected_desc expected
        case expected
        when NilClass then "be nil"
        else
          "match #{expected.inspect}"
        end
      end

      def actual_desc actual
        actual.nil? ? 'nil' : '"' + actual + '"'
      end

    end
  end
end