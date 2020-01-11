require 'pact/provider/help/pact_diff'

module Pact
  module Provider
    module Help
      class Content

        def initialize pact_sources
          @pact_sources = pact_sources
        end

        def text
          help_text + "\n\n" + pact_diffs
        end

        private

        attr_reader :pact_sources

        def help_text
          temp_dir = Pact.configuration.tmp_dir
          log_path = Pact.configuration.log_path
          ERB.new(template_string).result(binding)
        end

        def template_string
          File.read(File.expand_path( '../../../templates/help.erb', __FILE__))
        end

        def pact_diffs
          pact_sources.collect do | pact_json |
            PactDiff.call(pact_json)
          end.compact.join("\n")
        end
      end
    end
  end
end
