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
      !self.key?(:body) || body.empty?
    end

    def [] key
      super key.to_sym
    end

    def self.from_hash hash
      headers = Headers.new(hash[:headers] || hash['headers'] || {})
      new(symbolize_keys(hash).merge(headers: headers))
    end

  end

end