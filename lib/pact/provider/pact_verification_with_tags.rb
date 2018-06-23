module Pact::Provider
  class PactVerificationWithTags
    attr_reader :uri
    def initialize(uri)
      @uri = uri
    end

    def ==(other)
      other.is_a?(PactVerificationWithTags) &&
        uri == other.uri
    end
  end
end
