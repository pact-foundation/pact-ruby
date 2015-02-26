module Pact
  module Provider
    class PactRepositoryUri
      attr_reader :uri, :options

      def initialize (uri, options={})
        @uri = uri
        @options = options
      end

      def == other
        other.is_a?(PactRepositoryUri) &&
          uri == other.uri &&
          options == other.options
      end
    end
  end
end