require 'pact/hal/entity'
require 'pact/hal/http_client'
require 'pact/provider/pact_uri'
require 'pact/errors'

module Pact
  module PactBroker
    class FetchPendingPacts
      attr_reader :provider, :tags, :broker_base_url, :http_client_options, :http_client, :index_entity

      PENDING_PROVIDER_RELATION = 'beta:pending-provider-pacts'.freeze
      WIP_PROVIDER_RELATION = 'beta:wip-provider-pacts'.freeze # deprecated
      PACTS = 'pacts'.freeze
      PB_PACTS = 'pb:pacts'.freeze
      HREF = 'href'.freeze

      def initialize(provider, broker_base_url, http_client_options)
        @provider = provider
        @http_client_options = http_client_options
        @broker_base_url = broker_base_url
        @http_client = Pact::Hal::HttpClient.new(http_client_options)
      end

      def self.call(provider, broker_base_url, http_client_options)
        new(provider, broker_base_url, http_client_options).call
      end

      def call
        if index.success?
          pending_pacts_for_provider
        else
          raise Pact::Error.new("Error retrieving #{broker_base_url} status=#{index_entity.response.code} #{index_entity.response.raw_body}")
        end
      end

      private

      def index
        @index_entity ||= Pact::Hal::Link.new({ "href" => broker_base_url }, http_client).get
      end

      def pending_pacts_for_provider
        link = index_entity._link(WIP_PROVIDER_RELATION, PENDING_PROVIDER_RELATION)
        if link
          get_pact_urls(link.expand(provider: provider).get)
        else
          []
        end
      end

      def get_pact_urls(link_by_provider)
        link_by_provider.fetch(PB_PACTS, PACTS).collect do |pact|
          Pact::Provider::PactURI.new(pact[HREF], http_client_options)
        end
      end
    end
  end
end
