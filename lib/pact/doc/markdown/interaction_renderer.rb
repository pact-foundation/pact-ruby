require 'pact/doc/markdown/interaction_view_model'

module Pact
  module Doc
    module Markdown
      class InteractionRenderer

        attr_reader :interaction

        def initialize interaction, pact
          @interaction = InteractionViewModel.new(interaction, pact)
        end

        def render
          ERB.new(template_string).result(binding)
        end

        def template_string
          File.read( template_file )
        end

        def template_file
          File.dirname(__FILE__) + '/interaction.erb'
        end
      end
    end
  end
end