require 'pact/shared/request'
require 'pact/shared/key_not_found'

module Pact
  module Consumer
    module Request
      class Actual < Pact::Request::Base

        def self.from_hash(hash)
          sym_hash = symbolize_keys hash
          method = sym_hash.fetch(:method)
          path = sym_hash.fetch(:path)
          query = sym_hash.fetch(:query)
          headers = sym_hash.fetch(:headers)
          body = sym_hash.fetch(:body, nil)
          new(method, path, headers, body, query)
        end

        protected

        def self.key_not_found
          nil
        end
      end
    end
  end
end