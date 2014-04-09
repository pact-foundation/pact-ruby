module Pact
  module Doc
    module Markdown
      class InteractionViewModel

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
          JSON.pretty_generate(Reification.from_term(@interaction.request))
        end

        def response
          JSON.pretty_generate(Reification.from_term(@interaction.response))
        end

        def sortable_id
          @sortable_id ||= "#{interaction.description.downcase} #{interaction.response['status']} #{(interaction.provider_state || '').downcase}"
        end

        private

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
end