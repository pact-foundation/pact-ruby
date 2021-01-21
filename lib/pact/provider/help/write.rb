require 'pact/provider/help/content'
require 'fileutils'
require 'pact/consumer/configuration'

module Pact
  module Provider
    module Help
      class Write

        HELP_FILE_NAME = 'help.md'

        def self.call pact_sources, reports_dir = Pact.configuration.reports_dir
          new(pact_sources, reports_dir).call
        end

        def initialize pact_sources, reports_dir
          @pact_sources = pact_sources
          @reports_dir = File.expand_path(reports_dir)
        end

        def call
          clean_reports_dir
          write
        rescue StandardError => e
          Pact.configuration.error_stream.puts("ERROR: Error generating help output - #{e.class} #{e.message} \n" + e.backtrace.join("\n"))
        end

        private

        attr_reader :reports_dir, :pact_sources

        def clean_reports_dir
          raise "Cleaning report dir #{reports_dir} would delete project!" if reports_dir_contains_pwd
          FileUtils.rm_rf reports_dir
          FileUtils.mkdir_p reports_dir
        end

        def reports_dir_contains_pwd
          Dir.pwd.start_with?(reports_dir)
        end

        def write
          File.open(help_path, "w") { |file| file << help_text }
        end

        def help_path
          File.join(reports_dir, 'help.md')
        end

        def help_text
          Content.new(pact_sources).text
        end
      end
    end
  end
end
