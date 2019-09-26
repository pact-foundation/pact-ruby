require 'pact/shared/dsl'
require 'pact/provider/world'
require 'pact/pact_broker/fetch_pact_uris_for_verification'
require 'pact/errors'

module Pact
  module Provider
    module Configuration
      class PactVerificationFromBroker

        extend Pact::DSL

        # If user declares a variable with the same name as one of these attributes
        # in parent scope, it will clash with these ones,
        # so put an underscore in front of the name to be safer.

        attr_accessor :_provider_name, :_pact_broker_base_url, :_consumer_version_tags, :_provider_version_tags, :_basic_auth_options, :_verbose

        def initialize(provider_name, provider_version_tags)
          @_provider_name = provider_name
          @_provider_version_tags = provider_version_tags
          @_consumer_version_tags = []
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
            _provider_version_tags,
            _pact_broker_base_url,
            _basic_auth_options.merge(verbose: _verbose)
          )

          Pact.provider_world.add_pact_uri_source fetch_pacts
        end

        def consumer_version_selectors
          # TODO support "all"
          _consumer_version_tags.collect do | tag |
            {
              tag: tag,
              latest: true
            }
          end
        end

        def validate
          raise Pact::Error.new("Please provide a pact_broker_base_url from which to retrieve the pacts") unless _pact_broker_base_url
        end
      end
    end
  end
end