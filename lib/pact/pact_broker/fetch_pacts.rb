require 'pact/hal/entity'
require 'pact/hal/http_client'

module Pact
  module PactBroker
    class FetchPacts
      attr_reader :provider, :tags, :broker_base_url, :basic_auth_options, :http_client, :index_entity, :all_pacts

      ALL_PROVIDER_TAG_RELATION = 'pb:provider-pacts-with-tag'.freeze
      LATEST_PROVIDER_TAG_RELATION = 'pb:latest-provider-pacts-with-tag'.freeze
      ALL_PROVIDER_RELATION = 'pb:provider-pacts'.freeze
      LATEST_PROVIDER_RELATION = 'pb:latest-provider-pacts'.freeze
      PACTS = 'pacts'.freeze
      HREF = 'href'.freeze

      def initialize(provider, tags, broker_base_url, basic_auth_options, all_pacts)
        @provider = provider
        @tags = tags
        @broker_base_url = broker_base_url
        @http_client = Pact::Hal::HttpClient.new(basic_auth_options)
        @all_pacts = all_pacts
      end

      def self.call(provider, tags, broker_base_url, basic_auth_options, all_pacts)
        new(provider, tags, broker_base_url, basic_auth_options, all_pacts).call
      end

      def call
        get_index
        if tags && tags.any?
          get_tagged_pacts_for_provider
        else
          get_pacts_for_provider
        end
      end

      private

      def get_pacts_for_provider
        if all_pacts
          get_all_pacts_for_provider
        else
          get_latest_pacts_for_provider
        end
      end

      def get_tagged_pacts_for_provider
        if all_pacts
          get_all_tagged_pacts_for_provider
        else
          get_latest_tagged_pacts_for_provider
        end
      end

      def get_index
        response = http_client.get(broker_base_url)
        @index_entity = Pact::Hal::Entity.new(response.body, http_client)
      end

      def get_latest_tagged_pacts_for_provider
        link = index_entity._link(LATEST_PROVIDER_TAG_RELATION)
        tags.collect do | tag |
          get_pact_urls(link.expand(provider: provider, tag: tag).get)
        end.flatten
      end

      def get_all_tagged_pacts_for_provider
        link = index_entity._link(ALL_PROVIDER_TAG_RELATION)
        tags.collect do |tag|
          get_pact_urls(link.expand(provider: provider, tag: tag).get)
        end.flatten
      end

      def get_latest_pacts_for_provider
        link = index_entity._link(LATEST_PROVIDER_RELATION)
        get_pact_urls(link.expand(provider: provider).get)
      end

      def get_all_pacts_for_provider
        link = index_entity._link(ALL_PROVIDER_RELATION)
        get_pact_urls(link.expand(provider: provider).get)
      end

      def get_pact_urls(link_by_provider)
        link_by_provider.fetch(PACTS).collect{ |pact | pact[HREF] }
      end
    end
  end
end