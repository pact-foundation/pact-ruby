require 'pact/consumer_contract/active_support_support'
require 'colored'

module Pact
  module Matchers
    class NestedJsonDiffDecorator

      include Pact::ActiveSupportSupport

      EXPECTED = '"EXPECTED"'
      EXPECTED_COLOURED = '"' + "expected".red + '"'

      EXPECTED_REGEXP = '"EXPECTED_TO_MATCH"'
      EXPECTED_REGEXP_COLOURED = '"' + "expected_to_match".red + '"'


      ACTUAL = '"ACTUAL"'
      ACTUAL_COLOURED =  '"' + "actual".green + '"'

      attr_reader :diff

      def initialize diff
        @diff = diff
      end

      def to_hash
        diff
      end

      def to_s
        colourise_message_if_configured fix_json_formatting(diff.to_json)
      end

      def colourise_message_if_configured message
        if Pact.configuration.color_enabled
          colourise_message message
        else
          message
        end
      end

      def colourise_message message
        message.split("\n").collect{| line | colourise(line) }.join("\n")
      end

      def colourise line
        line.white.gsub(EXPECTED, EXPECTED_COLOURED).gsub(ACTUAL, ACTUAL_COLOURED).gsub(EXPECTED_REGEXP, EXPECTED_REGEXP_COLOURED)
      end

    end

  end
end