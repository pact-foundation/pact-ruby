module Pact::Provider
  class PactVerificationWithTags
    attr_reader :tags, :uri
    def initialize(tags, uri)
      @tags = tags
      @uri = uri
    end

    def ==(other)
      other.is_a?(PactVerificationWithTags) &&
        tags == other.tags &&
        uri == other.uri
    end
  end
end
