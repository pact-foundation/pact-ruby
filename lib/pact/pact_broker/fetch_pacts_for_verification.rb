require 'pact/hal/entity'
require 'pact/hal/http_client'
require 'pact/provider/pact_uri'
require 'pact/errors'

module Pact
  module PactBroker
    class FetchPactsForVerification
      attr_reader :provider, :query, :broker_base_url, :http_client_options, :http_client

      PACTS_FOR_VERIFICATION_RELATION = 'beta:provider-pacts-for-verification'.freeze
      PACTS = 'pacts'.freeze
      HREF = 'href'.freeze
      LINKS = '_links'.freeze
      SELF = 'self'.freeze
      EMBEDDED = '_embedded'.freeze

      def initialize(provider, query, broker_base_url, http_client_options)
        @provider = provider
        @query = query
        @http_client_options = http_client_options
        @broker_base_url = broker_base_url
        @http_client = Pact::Hal::HttpClient.new(http_client_options)
      end

      def self.call(provider, query, broker_base_url, http_client_options)
        new(provider, query, broker_base_url, http_client_options).call
      end

      def call
        if index.can?(PACTS_FOR_VERIFICATION_RELATION)
          log_message
          pacts_for_verification
        else
          []
        end
      end

      private

      def tagged_pacts_for_provider
        tags.collect do |tag|
          link = link_for(tag)
          urls = pact_urls(link.expand(provider: provider, tag: tag[:name]).get)
          if urls.empty? && tag[:fallback]
            urls = pact_urls(link.expand(provider: provider, tag: tag[:fallback]).get)
          end
          urls
        end.flatten
      end

      def index
        @index_entity ||= Pact::Hal::Link.new({ "href" => broker_base_url }, http_client).get.assert_success!
      end

      def pacts_for_verification
        pacts_for_verification_entity.response.body[EMBEDDED][PACTS].collect do | pact |
          metadata = {
            pending: pact["verificationProperties"]["pending"],
            pending_reason: pact["verificationProperties"]["pendingReason"],
            inclusion_reason: pact["verificationProperties"]["inclusionReason"],
          }
          Pact::Provider::PactURI.new(pact[LINKS][SELF][HREF], http_client_options, metadata)
        end
      end

      def pacts_for_verification_entity
        index
          ._link(PACTS_FOR_VERIFICATION_RELATION)
          .expand(provider: provider)
          .with_query(query)
          .get!
      end

      def log_message
        message = "INFO: Fetching pacts for #{provider} from #{broker_base_url}"
        Pact.configuration.output_stream.puts message
      end
    end
  end
end
