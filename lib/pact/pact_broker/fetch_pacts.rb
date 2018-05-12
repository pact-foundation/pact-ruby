require 'pact/hal/entity'
require 'pact/hal/http_client'

module Pact
  module PactBroker
    class FetchPacts
      attr_reader :provider, :tags, :broker_base_url, :basic_auth_options, :http_client, :pact_entity

      LATEST_PROVIDER_TAG_RELATION = 'pb:latest-provider-pacts-with-tag'.freeze
      LATEST_PROVIDER_RELATION = 'pb:latest-provider-pacts'.freeze
      PACTS = 'pacts'.freeze
      HREF = 'href'.freeze

      def initialize(provider, tags, broker_base_url, basic_auth_options)
        @provider = provider
        @tags = tags

        @http_client = Pact::Hal::HttpClient.new(basic_auth_options)
        @response = @http_client.get(broker_base_url)
        @pact_entity = Pact::Hal::Entity.new(@response.body, http_client)
      end

      def self.call(provider, tags = nil, broker_base_url, basic_auth_options)
        new(provider, tags, broker_base_url, basic_auth_options).call
      end

      def call
        pact_urls = []
        if tags
          link = pact_entity._link(LATEST_PROVIDER_TAG_RELATION)
          tags.each do |tag|
            link_by_tag = link.expand(provider: provider, tag: tag).get
            get_pact_urls(link_by_tag, pact_urls)
          end
        else
          link = pact_entity._link(LATEST_PROVIDER_RELATION)
          link_by_provider = link.expand(provider: provider).get
          get_pact_urls(link_by_provider, pact_urls)
        end
        pact_urls
      end

      private

      def get_pact_urls(link_by_provider, pact_urls)
        pacts = link_by_provider.fetch(PACTS)
        pacts.each do |pact|
          pact_urls.push(pact[HREF])
        end
      end
    end
  end
end