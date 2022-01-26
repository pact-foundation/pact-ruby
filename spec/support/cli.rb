module Pact
  module Support
    module CLI

      def execute_command command, options = {}
        output = `#{command}`
        ensure_patterns_present(command, options, output) if options[:with]
        ensure_patterns_not_present(command, options, output) if options[:without]
      end

      def ensure_patterns_present command, options, output
        options[:with].each do | pattern |
          raise ("Could not find #{pattern.inspect} in output of #{command}" + "\n\n#{output}") unless output =~ pattern
        end
      end

      def ensure_patterns_not_present command, options, output
        options[:without].each do | pattern |
          raise ("Expected not to find #{pattern.inspect} in output of #{command}" + "\n\n#{output}") if output =~ pattern
        end
      end

    end
  end
end
