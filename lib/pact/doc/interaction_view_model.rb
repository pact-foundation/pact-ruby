require 'pact/consumer_contract/active_support_support'

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
          if has_provider_state?
            "#{description} given #{interaction.provider_state}"
          else
            interaction.description
          end.gsub(/\s+/,'_')
        end
      end

      def request_method
        interaction.request.method.upcase
      end

      def request_path
        interaction.request.path
      end

      def response_status
        interaction.response['status']
      end

      def consumer_name
        @consumer_contract.consumer.name
      end

      def provider_name
        @consumer_contract.provider.name
      end

      def has_provider_state?
        @interaction.provider_state && !@interaction.provider_state.empty?
      end

      def provider_state start_of_sentence = false
        apply_capitals(@interaction.provider_state.strip, start_of_sentence)
      end

      def description start_of_sentence = false
        apply_capitals(@interaction.description.strip, start_of_sentence)
      end

      def request
        fix_json_formatting JSON.pretty_generate(clean_request)
      end

      def response
        fix_json_formatting JSON.pretty_generate(clean_response)
      end

      def sortable_id
        @sortable_id ||= "#{interaction.description.downcase} #{interaction.response['status']} #{(interaction.provider_state || '').downcase}"
      end

      private

      def clean_request
        request = Reification.from_term(@interaction.request).to_hash
        remove_key_if_empty :headers, request
        request
      end

      def clean_response
        response = Reification.from_term(@interaction.response)
        remove_key_if_empty "headers", response
        remove_key_if_empty "body", response
        response
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

      attr_reader :interaction, :consumer_contract

    end
  end
end