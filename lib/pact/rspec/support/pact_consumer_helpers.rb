# frozen_string_literal: true

require_relative "pact_message_helpers"
require "json"

module PactConsumerDsl
  include Pact::Matchers
  include Pact::Generators

  module ClassMethods
    def has_http_pact_between(consumer, provider, opts: {})
      _has_pact_between(:http, consumer, provider, opts: opts)
    end

    def has_grpc_pact_between(consumer, provider, opts: {})
      _has_pact_between(:grpc, consumer, provider, opts: opts)
    end

    def has_message_pact_between(consumer, provider, opts: {})
      _has_pact_between(:message, consumer, provider, opts: opts)
    end

    def has_plugin_http_pact_between(consumer, provider, opts: {})
      _has_pact_between(:plugin_http, consumer, provider, opts: opts)
    end

    def has_plugin_sync_message_pact_between(consumer, provider, opts: {})
      _has_pact_between(:plugin_sync_message, consumer, provider, opts: opts)
    end

    def has_plugin_async_message_pact_between(consumer, provider, opts: {})
      _has_pact_between(:plugin_async_message, consumer, provider, opts: opts)
    end

    def _has_pact_between(transport_type, consumer, provider, opts: {})
      raise "has_#{transport_type}_pact_between is designed to be used with RSpec 3+" unless defined?(::RSpec)
      raise "has_#{transport_type}_pact_between has to be declared at the top level of a suite" unless top_level?
      raise "has_*_pact_between cannot be declared more than once per suite" if defined?(@_pact_config)

      # rubocop:disable RSpec/BeforeAfterAll
      before(:context) do
        @_pact_config = Pact::Consumer::PactConfig.new(transport_type, consumer_name: consumer, provider_name: provider, opts: opts)
      end
      # rubocop:enable RSpec/BeforeAfterAll
    end
  end

  def new_interaction(description = nil)
    pact_config.new_interaction(description)
  end

  def reset_pact # rubocop:disable Rails/Delegate
    pact_config.reset_pact
  end

  def pact_config
    instance_variable_get(:@_pact_config)
  end

  def execute_http_pact
    raise InteractionBuilderError.new("interaction is designed to be used one-time only") if defined?(@used)
    mock_server = Pact::Consumer::MockServer.create_for_http!(
      pact: pact_config.pact_handle, host: pact_config.mock_host, port: pact_config.mock_port
    )

    yield(mock_server)

  ensure
    if mock_server.matched?
      mock_server.write_pacts!(pact_config.pact_dir)
    else
      msg = mismatches_error_msg(mock_server)
      raise Pact::Consumer::HttpInteractionBuilder::InteractionMismatchesError.new(msg)
    end
    @used = true
    mock_server&.cleanup
    reset_pact
  end


  def mismatches_error_msg(mock_server)
    rspec_example_desc = RSpec.current_example&.description
    mismatches = JSON.pretty_generate(JSON.parse(mock_server.mismatches))
    mismatches_with_colored_keys = mismatches.gsub(/"([^"]+)":/) { |match| "\e[34m#{match}\e[0m" } # Blue keys / white values

    "#{rspec_example_desc} has mismatches: #{mismatches_with_colored_keys}"
  end
end

RSpec.configure do |config|
  config.include PactConsumerDsl, pact_entity: :consumer
  config.extend PactConsumerDsl::ClassMethods, pact_entity: :consumer
end
