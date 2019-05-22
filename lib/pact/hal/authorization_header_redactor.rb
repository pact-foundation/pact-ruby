require 'delegate'

module Pact
  module Hal
    class AuthorizationHeaderRedactor < SimpleDelegator
      def puts(*args)
        __getobj__().puts(*redact_args(args))
      end

      def print(*args)
        __getobj__().puts(*redact_args(args))
      end

      def <<(*args)
        __getobj__().send(:<<, *redact_args(args))
      end

      private

      attr_reader :redactions

      def redact_args(args)
        args.collect{ | s| redact(s) }
      end

      def redact(string)
        return string unless string.is_a?(String)
        string.gsub(/Authorization: .*\\r\\n/, "Authorization: [redacted]\\r\\n")
      end
    end
  end
end
