module Pact::Provider
  class PactVerification
    attr_reader :consumer_name, :uri, :ref
    def initialize consumer_name, uri, ref
      @consumer_name = consumer_name
      @uri = uri
      @ref = ref
    end

    def == other
      other.is_a?(PactVerification) &&
        consumer_name == other.consumer_name &&
        uri == other.uri &&
        ref == other.ref
    end
  end
end