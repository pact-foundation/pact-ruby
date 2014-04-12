require 'pact/doc/interaction_view_model'

module Pact
  module Doc
    module Markdown
      class InteractionRenderer

        attr_reader :interaction

        def initialize interaction, pact
          @interaction = InteractionViewModel.new(interaction, pact)
        end

        def render_summary
          suffix = interaction.has_provider_state? ? " given #{interaction.provider_state}" : ""
          "* [#{interaction.description(true)}](##{interaction.id})#{suffix}\n\n"
        end

        def render_full_interaction
          render('/interaction.erb')
        end

        def render template_file
          ERB.new(template_string(template_file)).result(binding)
        end

        def template_string(template_file)
          File.read( template_contents(template_file) )
        end

        def template_contents(template_file)
          File.dirname(__FILE__) + template_file
        end

      end
    end
  end
end