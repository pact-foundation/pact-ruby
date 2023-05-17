require 'pact/consumer/configuration'
require 'term/ansicolor'
require 'pathname'

module Pact
  module Provider
    module Help
      class PromptText

        C = ::Term::ANSIColor

        def self.call reports_dir = Pact.configuration.reports_dir, options = {color: Pact.configuration.color_enabled}
          new(reports_dir, options).call
        end

        def initialize reports_dir, options
          @reports_dir = File.expand_path(reports_dir)
          @options = options
        end

        def call
          options[:color] ? prompt_text_colored : prompt_text_plain
        end

        private

        attr_reader :reports_dir, :options

        def prompt_text_plain
          "For assistance debugging failures, run `bundle exec rake pact:verify:help#{rake_args}`\n"
        end

        def prompt_text_colored
          C.yellow(prompt_text_plain)
        end

        def rake_args
          if reports_dir == Pact.configuration.default_reports_dir
            ''
          else
            "[#{relative_reports_dir}]"
          end
        end

        def relative_reports_dir
          Pathname.new(reports_dir).relative_path_from(Pathname.new(Dir.pwd))
        end
      end
    end
  end
end
