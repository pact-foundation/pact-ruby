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

      def basic_auth?
        !!username
      end

      def username
        options[:username]
      end

      def password
        options[:password]
      end

      def to_s
        if(basic_auth?)
          URI(@uri).tap { |x| x.userinfo="#{username}:*****"}.to_s
        else
          @uri
        end
      end
    end
  end
end
