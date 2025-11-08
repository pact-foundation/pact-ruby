# frozen_string_literal: true

require_relative "pact_config/grpc"

module Pact
  module Consumer
    module PactConfig
      def self.new(transport_type, consumer_name:, provider_name:, opts: {})
        case transport_type
        when :http
          Http.new(consumer_name: consumer_name, provider_name: provider_name, opts: opts)
        when :grpc
          Grpc.new(consumer_name: consumer_name, provider_name: provider_name, opts: opts)
        when :message
          Message.new(consumer_name: consumer_name, provider_name: provider_name, opts: opts)
        when :plugin_sync_message
          PluginSyncMessage.new(consumer_name: consumer_name, provider_name: provider_name, opts: opts)
        when :plugin_async_message
          PluginAsyncMessage.new(consumer_name: consumer_name, provider_name: provider_name, opts: opts)
        when :plugin_http
          PluginHttp.new(consumer_name: consumer_name, provider_name: provider_name, opts: opts)
        else
          raise ArgumentError, "unknown transport_type: #{transport_type}"
        end
      end
    end
  end
end
