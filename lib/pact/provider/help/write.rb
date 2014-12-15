require 'pact/provider/help/content'
require 'fileutils'

#TODO add report_dir to configuration

module Pact
  module Provider
    module Help
      class Write

        def self.call report_dir
          new(report_dir).call
        end

        def initialize report_dir
          @report_dir = File.expand_path(report_dir || "./report/pact")
          puts @report_dir
        end

        def call
          clean_report_dir
          write
        end

        private

        attr_reader :report_dir

        def clean_report_dir
          raise "Cleaning report dir #{report_dir} would delete project!" if report_dir_contains_pwd
          FileUtils.rm_rf report_dir
          FileUtils.mkdir_p report_dir
        end

        def report_dir_contains_pwd
          Dir.pwd.start_with?(report_dir)
        end

        def write
          File.open(help_path, "w") { |file| file << help_text }
        end

        def help_path
          File.join(report_dir, 'help.txt')
        end

        def help_text
          Content.new.text
        end

      end
    end
  end
end
