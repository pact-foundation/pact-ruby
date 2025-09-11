# frozen_string_literal: true

# require_relative "pact_config/grpc"

module Pact
  module V2
    module Provider
      module PactConfig
        def self.new(transport_type, provider_name:, opts: {})
          case transport_type
          when :http
            Http.new(provider_name: provider_name, opts: opts)
          when :grpc
            Grpc.new(provider_name: provider_name, opts: opts)
          when :async
            Async.new(provider_name: provider_name, opts: opts)
          when :mixed
            Mixed.new(provider_name: provider_name, opts: opts)
          else
            raise ArgumentError, "unknown transport_type: #{transport_type}"
          end
        end
      end
    end
  end
end
