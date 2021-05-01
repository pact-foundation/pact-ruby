module Pact
  module Provider
    class PactURI
      attr_reader :uri, :options, :metadata

      def initialize (uri, options = nil, metadata = nil)
        @uri = uri
        @options = options || {}
        @metadata = metadata || {} # make sure it's not nil if nil is passed in
      end

      def == other
        other.is_a?(PactURI) &&
          uri == other.uri &&
          options == other.options &&
          metadata == other.metadata
      end

      def basic_auth?
        !!username && !!password
      end

      def username
        options[:username]
      end

      def password
        options[:password]
      end

      def to_s
        if basic_auth? && http_or_https_uri?
          begin
            URI(@uri).tap { |x| x.userinfo="#{username}:*****"}.to_s
          rescue URI::InvalidComponentError
            URI(@uri).tap { |x| x.userinfo="*****:*****"}.to_s
          end
        elsif personal_access_token? && http_or_https_uri?
          URI(@uri).tap { |x| x.userinfo="*****"}.to_s
        else
          uri
        end
      end

      private def personal_access_token?
        !!username && !password
      end

      private def http_or_https_uri?
        uri.start_with?('http://', 'https://')
      end

    end
  end
end
