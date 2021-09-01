require 'pact/shared/dsl'
require 'pact/provider/world'
require 'pact/pact_broker/fetch_pact_uris_for_verification'
require 'pact/errors'
require 'pact/utils/string'

module Pact
  module Provider
    module Configuration
      class PactVerificationFromBroker

        extend Pact::DSL

        # If user declares a variable with the same name as one of these attributes
        # in parent scope, it will clash with these ones,
        # so put an underscore in front of the name to be safer.

        attr_accessor :_provider_name, :_pact_broker_base_url, :_consumer_version_tags, :_provider_version_branch, :_provider_version_tags, :_basic_auth_options, :_enable_pending, :_include_wip_pacts_since, :_verbose, :_consumer_version_selectors

        def initialize(provider_name, provider_version_branch, provider_version_tags)
          @_provider_name = provider_name
          @_provider_version_branch = provider_version_branch
          @_provider_version_tags = provider_version_tags
          @_consumer_version_tags = []
          @_consumer_version_selectors = []
          @_enable_pending = false
          @_include_wip_pacts_since = nil
          @_verbose = false
        end

        dsl do
          def pact_broker_base_url pact_broker_base_url, basic_auth_options = {}
            self._pact_broker_base_url = pact_broker_base_url
            self._basic_auth_options = basic_auth_options
          end

          def consumer_version_tags consumer_version_tags
            self._consumer_version_tags = *consumer_version_tags
          end

          def consumer_version_selectors consumer_version_selectors
            self._consumer_version_selectors = *consumer_version_selectors
          end

          def enable_pending enable_pending
            self._enable_pending = enable_pending
          end

          def include_wip_pacts_since since
            self._include_wip_pacts_since = if since.respond_to?(:xmlschema)
              since.xmlschema
            else
              since
            end
          end

          def verbose verbose
            self._verbose = verbose
          end
        end

        def finalize
          validate
          create_pact_verification
        end

        private

        def create_pact_verification
          fetch_pacts = Pact::PactBroker::FetchPactURIsForVerification.new(
            _provider_name,
            consumer_version_selectors,
            _provider_version_branch,
            _provider_version_tags,
            _pact_broker_base_url,
            _basic_auth_options.merge(verbose: _verbose),
            { include_pending_status: _enable_pending, include_wip_pacts_since: _include_wip_pacts_since }
          )

          Pact.provider_world.add_pact_uri_source fetch_pacts
        end

        def consumer_version_selectors
          convert_tags_to_selectors + convert_consumer_version_selectors
        end

        def convert_tags_to_selectors
          _consumer_version_tags.collect do | tag |
            if tag.is_a?(Hash)
              {
                tag: tag.fetch(:name),
                latest: !tag[:all],
                fallbackTag: tag[:fallback]
              }
            elsif tag.is_a?(String)
              {
                tag: tag,
                latest: true
              }
            else
              raise Pact::Error.new("The value supplied for consumer_version_tags must be a String or a Hash. Found #{tag.class}")
            end
          end
        end

        def convert_consumer_version_selectors
          _consumer_version_selectors.collect do | selector |
            selector.each_with_object({}) do | (key, value), new_selector |
              new_selector[Pact::Utils::String.camelcase(key.to_s).to_sym] = value
            end
          end
        end

        def validate
          raise Pact::Error.new("Please provide a pact_broker_base_url from which to retrieve the pacts") unless _pact_broker_base_url
        end
      end
    end
  end
end