require 'pact/shared/active_support_support'
require 'term/ansicolor'

module Pact
  module Matchers
    class EmbeddedDiffFormatter

      include Pact::ActiveSupportSupport
      C = ::Term::ANSIColor


      EXPECTED = /"EXPECTED([A-Z_]*)":/

      ACTUAL = /"ACTUAL([A-Z_]*)":/

      attr_reader :diff, :colour

      def initialize diff, options = {}
        @diff = diff
        @colour = options.fetch(:colour, false)
      end

      def self.call diff, options = {colour: Pact.configuration.color_enabled}
        new(diff, options).call
      end

      def call
        to_s
      end

      def to_hash
        diff
      end

      def to_s
        colourise_message_if_configured fix_json_formatting(diff.to_json)
      end

      def colourise_message_if_configured message
        if colour
          colourise_message message
        else
          message
        end
      end

      def colourise_message message
        message.split("\n").collect{| line | colourise(line) }.join("\n")
      end

      def colourise line
        line.gsub(EXPECTED){|match| coloured_key match, :red }.gsub(ACTUAL){ | match | coloured_key match, :green }
      end

      def coloured_key match, colour
        '"' + C.color(colour, match.downcase.gsub(/^"|":$/,'')) + '":'
      end

    end

  end
end