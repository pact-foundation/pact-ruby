module RSpec
  module Core

    class BacktraceFormatter

      # RSpec 3 has a hardwired @system_exclusion_patterns which removes everything matching /bin\//
      # This causes *all* the backtrace lines to be cleaned, as rake pact:verify now shells out
      # to the executable `pact verify ...`
      # which then causes *all* the lines to be included

      def exclude?(line)
        return false if @full_backtrace
        matches_an_exclusion_pattern?(line) &&
        @inclusion_patterns.none? { |p| p =~ line }
      end

    end
  end
end
