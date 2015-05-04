module Pact
  module Provider
    class PactURI
      attr_reader :uri, :options

      def initialize (uri, options={})
        @uri = uri
        @options = options
      end

      def == other
        other.is_a?(PactURI) &&
          uri == other.uri &&
          options == other.options
      end

      def to_s
        if(options[:username])
          URI(@uri).tap { |x| x.userinfo="#{options[:username]}:*****"}.to_s
        else
          @uri
        end

      end
    end
  end
end