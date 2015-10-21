require 'pact/shared/active_support_support'
require 'pact/reification'
require 'cgi'

module Pact
  module Doc
    class InteractionViewModel

      include Pact::ActiveSupportSupport

      def initialize interaction, consumer_contract
        @interaction = interaction
        @consumer_contract = consumer_contract
      end

      def id
        @id ||= begin
          full_desc = if has_provider_state?
            "#{description} given #{interaction.provider_state}"
          else
            description
          end
          CGI.escapeHTML(full_desc.gsub(/\s+/,'_'))
        end
      end

      def request_method
        interaction.request.method.upcase
      end

      def request_path
        interaction.request.path
      end

      def response_status
        interaction.response.status
      end

      def consumer_name
        markdown_escape @consumer_contract.consumer.name
      end

      def provider_name
        markdown_escape @consumer_contract.provider.name
      end

      def has_provider_state?
        @interaction.provider_state && !@interaction.provider_state.empty?
      end

      def provider_state start_of_sentence = false
        markdown_escape apply_capitals(@interaction.provider_state.strip, start_of_sentence)
      end

      def description start_of_sentence = false
        return '' unless @interaction.description
        markdown_escape apply_capitals(@interaction.description.strip, start_of_sentence)
      end

      def request
        fix_json_formatting JSON.pretty_generate(clean_request)
      end

      def response
        fix_json_formatting JSON.pretty_generate(clean_response)
      end

      private

      attr_reader :interaction, :consumer_contract

      def clean_request
        reified_request = Reification.from_term(interaction.request)
        ordered_clean_hash(reified_request).tap do | hash |
          hash[:body] = reified_request[:body] if reified_request[:body]
        end
      end

      def clean_response
        ordered_clean_hash Reification.from_term(interaction.response)
      end

      # Remove empty body and headers hashes from response, and empty headers from request,
      # as an empty hash means "allow anything" - it's more intuitive and cleaner to just
      # remove the empty hashes from display.
      def ordered_clean_hash source
        ordered_keys.each_with_object({}) do |key, target|
          if source.key? key
            target[key] = source[key] unless value_is_an_empty_hash(source[key])
          end
        end
      end

      def value_is_an_empty_hash value
        value.is_a?(Hash) && value.empty?
      end

      def ordered_keys
        [:method, :path, :query, :status, :headers, :body]
      end

      def remove_key_if_empty key, hash
        hash.delete(key) if hash[key].is_a?(Hash) && hash[key].empty?
      end

      def apply_capitals string, start_of_sentence = false
        start_of_sentence ? capitalize_first_letter(string) : lowercase_first_letter(string)
      end

      def capitalize_first_letter string
        string[0].upcase + string[1..-1]
      end

      def lowercase_first_letter string
        string[0].downcase + string[1..-1]
      end

      def markdown_escape string
        return nil unless string
        string.gsub('*','\*').gsub('_','\_')
      end
    end
  end
end
