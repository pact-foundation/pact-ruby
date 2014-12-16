require 'pact/provider/help/content'
require 'fileutils'
require 'pact/consumer/configuration'
require 'pact/provider/help/write'
require 'term/ansicolor'

module Pact
  module Provider
    module Help
      class ConsoleText

        C = ::Term::ANSIColor

        def self.call reports_dir = Pact.configuration.reports_dir, options = {color: true}
          new(reports_dir || Pact.configuration.reports_dir, options).call
        end

        def initialize reports_dir, options
          @reports_dir = File.expand_path(reports_dir)
          @options = options
        end

        def call
          begin
            options[:color] ? ColorizeMarkdown.(help_text) : help_text
          rescue Errno::ENOENT
            options[:color] ? error_text_coloured : error_text_plain
          end
        end

        private

        attr_reader :reports_dir, :options

        def help_text
          File.read(help_file_path)
        end

        def help_file_path
          File.join(reports_dir, Write::HELP_FILE_NAME)
        end

        def error_text_plain
          "Sorry, could not find help file at #{help_file_path}. Please ensure you have run `rake pact:verify`.\n" +
           "If this does not fix the problem, please raise a github issues for this bug."
        end

        def error_text_coloured
          C.red(error_text_plain)
        end

        class ColorizeMarkdown

          C = ::Term::ANSIColor

          def self.call markdown
            markdown.split("\n").collect do | line |
              if line.start_with?("# ")
                yellow_underling line.gsub(/^# /, '')
              elsif line.start_with?("* ")
                green("* ") + line.gsub(/^\* /, '')
              else
                line
              end
            end.join("\n")
          end

          def self.yellow_underling string
            C.underline(C.yellow(string))
          end

          def self.green string
            C.green(string)
          end

        end
      end
    end
  end
end
