require 'pact/hal/entity'
require 'pact/hal/http_client'

module Pact
  module PactBroker
    class FetchPacts
      attr_reader :provider, :tags, :broker_base_url, :basic_auth_options, :http_client, :index_entity

      ALL_PROVIDER_TAG_RELATION = 'pb:provider-pacts-with-tag'.freeze
      LATEST_PROVIDER_TAG_RELATION = 'pb:latest-provider-pacts-with-tag'.freeze
      LATEST_PROVIDER_RELATION = 'pb:latest-provider-pacts'.freeze
      PACTS = 'pacts'.freeze
      HREF = 'href'.freeze

      def initialize(provider, tags, broker_base_url, basic_auth_options)
        @provider = provider
        @tags = []
        if tags
          tags.collect do |tag|
            if tag.is_a?(String)
              @tags.push({name: tag, all: false})
            else
              @tags.push(tag)
            end
          end
        end
        @broker_base_url = broker_base_url
        @http_client = Pact::Hal::HttpClient.new(basic_auth_options)
      end

      def self.call(provider, tags, broker_base_url, basic_auth_options)
        new(provider, tags, broker_base_url, basic_auth_options).call
      end

      def call
        get_index
        tags&.any? ? get_tagged_pacts_for_provider : get_latest_pacts_for_provider
      end

      private

      def get_tagged_pacts_for_provider
        tags.collect do |tag|
          link = get_link(tag)
          get_pact_urls(link.expand(provider: provider, tag: tag[:name]).get)
        end.flatten
      end

      def get_link(tag)
        if !tag[:all]
          index_entity._link(LATEST_PROVIDER_TAG_RELATION)
        else
          index_entity._link(ALL_PROVIDER_TAG_RELATION)
        end
      end

      def get_index
        response = http_client.get(broker_base_url)
        @index_entity = Pact::Hal::Entity.new(response.body, http_client)
      end

      def get_latest_pacts_for_provider
        link = index_entity._link(LATEST_PROVIDER_RELATION)
        get_pact_urls(link.expand(provider: provider).get)
      end

      def get_pact_urls(link_by_provider)
        link_by_provider.fetch(PACTS).collect { |pact| pact[HREF] }
      end
    end
  end
end
