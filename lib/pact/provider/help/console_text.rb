require 'pact/provider/help/content'
require 'fileutils'
require 'pact/consumer/configuration'
require 'pact/provider/help/write'
require 'term/ansicolor'

module Pact
  module Provider
    module Help
      class ConsoleText

        def self.call reports_dir = Pact.configuration.reports_dir, options = {color: true}
          new(reports_dir, options).call
        end

        def initialize reports_dir, options
          @reports_dir = reports_dir
          @options = options
        end

        def call
          options[:color] ? ColorizeMarkdown.(help_text) : help_text

        end

        private

        attr_reader :reports_dir, :options

        def help_text
          File.read(File.join(reports_dir, Write::HELP_FILE_NAME))
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
