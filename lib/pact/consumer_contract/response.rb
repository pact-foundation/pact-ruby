require 'pact/consumer_contract/headers'
require 'pact/symbolize_keys'

module Pact

  class Response < Hash

    include SymbolizeKeys

    def initialize attributes
      merge!(attributes)
    end

    def status
      self[:status]
    end

    def headers
      self[:headers]
    end

    def body
      self[:body]
    end

    def body_allows_any_value?
      body_not_specified? || body_is_empty_hash?
    end

    def [] key
      super key.to_sym
    end

    def self.from_hash hash
      headers = Headers.new(hash[:headers] || hash['headers'] || {})
      new(symbolize_keys(hash).merge(headers: headers))
    end

    private

    def body_is_empty_hash?
      body.is_a?(Hash) && body.empty?
    end

    def body_not_specified?
      !self.key?(:body)
    end

  end

end