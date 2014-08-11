module RSpec
  module Core

    # RSpec 3 has a hardwired @system_exclusion_patterns which removes everything matching /bin\//
    # This causes *all* the backtrace lines to be cleaned, as rake pact:verify now shells out
    # to the executable `pact verify ...`
    # which then causes *all* the lines to be included as the BacktraceFormatter will
    # include all lines of the backtrace if all lines were filtered out.
    # This monkey patch only shows lines including bin/pact and removes the
    # "show all lines if no lines would otherwise be shown" logic.

    class BacktraceFormatter


      def format_backtrace(backtrace, options = {})
        return backtrace if options[:full_backtrace]
        backtrace.map { |l| backtrace_line(l) }.compact
      end

      def backtrace_line(line)
        relative_path(line) unless exclude?(line)
      rescue SecurityError
        nil
      end

      def exclude?(line)
        return false if @full_backtrace
        relative_line = relative_path(line)
        return true unless /bin\/pact/ =~ relative_line
      end

      # Copied from Metadata so a refactor can't break this overridden class
      def relative_path(line)
        line = line.sub(File.expand_path("."), ".")
        line = line.sub(/\A([^:]+:\d+)$/, '\\1')
        return nil if line == '-e:1'
        line
      rescue SecurityError
        nil
      end
    end
  end
end
