module Pact
  module Provider
    module Help
      class Content

        def initialize

        end

        def text
          help_text(Pact.configuration.tmp_dir, Pact.configuration.log_path)
        end

        private

        def help_text temp_dir, log_path
          ERB.new(template_string).result(binding)
        end

        def template_string
          File.read(File.expand_path( '../../../templates/help.erb', __FILE__))
        end
      end
    end
  end
end
