require 'pact/hal/entity'
require 'pact/hal/http_client'
require 'pact/provider/pact_uri'
require 'pact/errors'
require 'pact/pact_broker/fetch_pacts'
require 'pact/pact_broker/notices'
require 'pact/pact_broker/pact_selection_description'
require "pact/hash_refinements"

module Pact
  module PactBroker
    class FetchPactURIsForVerification
      using Pact::HashRefinements

      include PactSelectionDescription
      attr_reader :provider, :consumer_version_selectors, :provider_version_branch, :provider_version_tags, :broker_base_url, :http_client_options, :http_client, :options

      PACTS_FOR_VERIFICATION_RELATION = 'pb:provider-pacts-for-verification'.freeze
      PACTS_FOR_VERIFICATION_RELATION_BETA = 'beta:provider-pacts-for-verification'.freeze
      PACTS = 'pacts'.freeze
      HREF = 'href'.freeze
      LINKS = '_links'.freeze
      SELF = 'self'.freeze
      EMBEDDED = '_embedded'.freeze

      def initialize(provider, consumer_version_selectors, provider_version_branch, provider_version_tags, broker_base_url, http_client_options, options = {})
        @provider = provider
        @consumer_version_selectors = consumer_version_selectors || []
        @provider_version_branch = provider_version_branch
        @provider_version_tags = [*provider_version_tags]
        @http_client_options = http_client_options
        @broker_base_url = broker_base_url
        @http_client = Pact::Hal::HttpClient.new(http_client_options)
        @options = options
      end

      def self.call(provider, consumer_version_selectors, provider_version_branch, provider_version_tags, broker_base_url, http_client_options, options = {})
        new(provider, consumer_version_selectors, provider_version_branch, provider_version_tags, broker_base_url, http_client_options, options).call
      end

      def call
        if index.can?(PACTS_FOR_VERIFICATION_RELATION) || index.can?(PACTS_FOR_VERIFICATION_RELATION_BETA)
          log_message
          pacts_for_verification
        else
          old_selectors = consumer_version_selectors.collect do | selector |
            { name: selector[:tag], all: !selector[:latest], fallback: selector[:fallbackTag]}
          end
          # Fall back to old method of fetching pacts
          FetchPacts.call(provider, old_selectors, broker_base_url, http_client_options)
        end
      end

      private

      def index
        @index_entity ||= Pact::Hal::Link.new({ "href" => broker_base_url }, http_client).get.assert_success!
      end

      def pacts_for_verification
        pacts_for_verification_entity.response.body[EMBEDDED][PACTS].collect do | pact |
          metadata = {
            pending: pact["verificationProperties"]["pending"],
            notices: extract_notices(pact),
            short_description: pact["shortDescription"]
          }
          Pact::Provider::PactURI.new(pact[LINKS][SELF][HREF], http_client_options, metadata)
        end
      end

      def pacts_for_verification_entity
        index
          ._link(PACTS_FOR_VERIFICATION_RELATION, PACTS_FOR_VERIFICATION_RELATION_BETA)
          .expand(provider: provider)
          .post!(query)
      end

      def query
        q = {}
        q["includePendingStatus"] = options[:include_pending_status]
        q["consumerVersionSelectors"] = consumer_version_selectors if consumer_version_selectors.any?
        q["providerVersionTags"] = provider_version_tags if provider_version_tags.any?
        q["providerVersionBranch"] = provider_version_branch
        q["includeWipPactsSince"] = options[:include_wip_pacts_since]
        q.compact
      end

      def extract_notices(pact)
        Notices.new((pact["verificationProperties"]["notices"] || []).collect{ |notice| symbolize_keys(notice) })
      end

      def symbolize_keys(hash)
        hash.each_with_object({}){ |(k,v), h| h[k.to_sym] = v }
      end

      def log_message
        Pact.configuration.output_stream.puts "INFO: #{pact_selection_description(provider, consumer_version_selectors, options, broker_base_url)}"
      end
    end
  end
end
