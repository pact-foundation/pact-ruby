# frozen_string_literal: true

require_relative 'pact_message_helpers'
require_relative 'webmock/webmock_helpers'

module PactProducerDsl
  module ClassMethods
    PACT_PROVIDER_NOT_DECLARED_MESSAGE = 'http_pact_provider or grpc_pact_provider should be declared first'

    def http_pact_provider(provider, opts: {})
      _pact_provider(:http, provider, opts: opts)
    end

    def grpc_pact_provider(provider, opts: {})
      _pact_provider(:grpc, provider, opts: opts)
    end

    def message_pact_provider(provider, opts: {})
      _pact_provider(:async, provider, opts: opts)
    end

    def mixed_pact_provider(provider, opts: {})
      execute_mixed_pact_provider(:mixed, provider, opts: opts)
    end

    def execute_mixed_pact_provider(transport_type, provider, opts: {})
      raise "#{transport_type}_pact_provider is designed to be used with RSpec" unless defined?(::RSpec)
      raise "#{transport_type}_pact_provider has to be declared at the top level of a suite" unless top_level?
      if defined?(@_pact_config)
        raise 'mixed_pact_provider is designed to be run once per provider so cannot be declared more than once'
      end

      pact_config_instance = Pact::Provider::PactConfig.new(transport_type, provider_name: provider, opts: opts)
      instance_variable_set(:@_pact_config, pact_config_instance)

      before(:context) do
        # rspec allows only context ivars in specs and ignores the rest
        # so we use block-as-a-closure feature to save pact_config ivar reference and make it available for descendants
        @_pact_config = pact_config_instance
      end
      it "verifies mixed interactions with provider #{provider}" do
        pact_config.start_servers
        # TODO: call any available verifier, or exit if none specified
        pact_config.http_config.new_verifier(@_pact_config).verify!
      end
    end

    def _pact_provider(transport_type, provider, opts: {})
      raise "#{transport_type}_pact_provider is designed to be used with RSpec" unless defined?(::RSpec)
      raise "#{transport_type}_pact_provider has to be declared at the top level of a suite" unless top_level?
      if defined?(@_pact_config)
        raise '*_pact_provider is designed to be run once per provider so cannot be declared more than once'
      end

      pact_config_instance = Pact::Provider::PactConfig.new(transport_type, provider_name: provider, opts: opts)
      instance_variable_set(:@_pact_config, pact_config_instance)

      before(:context) do
        # rspec allows only context ivars in specs and ignores the rest
        # so we use block-as-a-closure feature to save pact_config ivar reference and make it available for descendants
        @_pact_config = pact_config_instance
      end
      it "verifies interactions with provider #{provider}" do
        pact_config.new_verifier.verify!
      end
    end

    def before_state_setup(&block)
      raise PACT_PROVIDER_NOT_DECLARED_MESSAGE unless pact_config

      pact_config.before_setup(&block)
    end

    def after_state_teardown(&block)
      raise PACT_PROVIDER_NOT_DECLARED_MESSAGE unless pact_config

      pact_config.after_teardown(&block)
    end

    def provider_state(name, opts: {}, &block)
      raise PACT_PROVIDER_NOT_DECLARED_MESSAGE unless pact_config

      pact_config.new_provider_state(name, opts: opts, &block)
    end

    def handle_message(name, opts: {}, &block)
      async_klass = Pact::Provider::PactConfig::Async
      if defined?(@_pact_config) &&
         @_pact_config.respond_to?(:async_config) &&
         @_pact_config.async_config.is_a?(async_klass)
        @_pact_config.async_config.new_message_handler(name, opts: opts, &block)
      elsif pact_config &&
            pact_config.respond_to?(:async_config) &&
            pact_config.async_config.is_a?(async_klass)
        pact_config.async_config.new_message_handler(name, opts: opts, &block)
      elsif defined?(@_pact_config) &&
            @_pact_config.is_a?(async_klass)
        @_pact_config.new_message_handler(name, opts: opts, &block)
      elsif pact_config.is_a?(async_klass)
        pact_config.new_message_handler(name, opts: opts, &block)

      else
        raise 'handle_message can only be used with message_pact_provider or mixed_pact_provider with an async block'
      end
    end

    def pact_config
      instance_variable_get(:@_pact_config)
    end
  end

  def pact_config
    instance_variable_get(:@_pact_config)
  end
end

RSpec.configure do |config|
  config.include PactProducerDsl, pact_entity: :provider
  config.extend PactProducerDsl::ClassMethods, pact_entity: :provider

  config.around pact_entity: :provider do |example|
    WebmockHelpers.turned_off do
      if defined?(::VCR)
        VCR.turned_off { example.run }
      else
        example.run
      end
    end
  end
end
