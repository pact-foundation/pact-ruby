require 'ostruct'
require 'logger'
require 'pact/doc/markdown/generator'
require 'pact/matchers/unix_diff_formatter'
require 'pact/matchers/embedded_diff_formatter'
require 'pact/matchers/list_diff_formatter'
require 'pact/shared/json_differ'
require 'pact/shared/text_differ'

module Pact

  class Configuration

    DOC_GENERATORS = { markdown: Pact::Doc::Markdown::Generator }

    DIFF_FORMATTERS = {
      :embedded => Pact::Matchers::EmbeddedDiffFormatter,
      :unix => Pact::Matchers::UnixDiffFormatter,
      :list => Pact::Matchers::ListDiffFormatter
    }

    class NilMatcher
      def self.=~ other
        other == nil ? 0 : nil
      end
    end

    DIFFERS = [
      [/json/, Pact::JsonDiffer],
      [NilMatcher, Pact::TextDiffer],
      [/.*/, Pact::TextDiffer]
    ]


    DEFAULT_DIFFER = Pact::TextDiffer

    attr_accessor :pact_dir
    attr_accessor :log_dir
    attr_accessor :doc_dir
    attr_accessor :reports_dir
    attr_writer :logger
    attr_accessor :tmp_dir
    attr_writer :pactfile_write_mode

    attr_accessor :error_stream
    attr_accessor :output_stream

    def self.default_configuration
      c = Configuration.new
      c.pact_dir = File.expand_path('./spec/pacts')
      c.tmp_dir = File.expand_path('./tmp/pacts')
      c.log_dir = default_log_dir
      c.pactfile_write_mode = :overwrite
      c.reports_dir = File.expand_path('./reports/pacts')
      c.doc_dir = File.expand_path("./doc/pacts")
      c.output_stream = $stdout
      c.error_stream = $stderr
      c
    end

    def initialize
      @differ_registration = []
    end

    def logger
      @logger ||= create_logger
    end

    def doc_generator= doc_generator
      doc_generators << begin
        if DOC_GENERATORS[doc_generator]
          DOC_GENERATORS[doc_generator]
        elsif doc_generator.respond_to?(:call)
          doc_generator
        else
          raise "Pact.configuration.doc_generator needs to respond to call, or be in the preconfigured list: #{DOC_GENERATORS.keys}"
        end
      end
    end

    def doc_generators
      @doc_generators  ||= []
    end

    def diff_formatter
      @diff_formatter ||= DIFF_FORMATTERS[:unix]
    end

    def diff_formatter= diff_formatter
      @diff_formatter = begin
        if DIFF_FORMATTERS[diff_formatter]
          DIFF_FORMATTERS[diff_formatter]
        elsif diff_formatter.respond_to?(:call)
          diff_formatter
        else
          raise "Pact.configuration.diff_formatter needs to respond to call, or be in the preconfigured list: #{DIFF_FORMATTERS.keys}"
        end
      end
    end

    def register_body_differ content_type, differ
      key = case content_type
      when String then Regexp.new(/^#{Regexp.escape(content_type)}$/)
      when Regexp then content_type
      when nil then NilMatcher
      else
        raise "Invalid content type used to register a differ (#{content_type.inspect}). Please use a Regexp or a String."
      end
      if !differ.respond_to?(:call)
        raise "Pact.configuration.register_body_differ expects a differ that is a lamda or a class/object that responds to call."
      end
      @differ_registration << [key, differ]
    end

    def differ_for_content_type content_type
      differs.find{ | differ_registration | differ_registration.first =~ content_type }.last
    end

    def log_path
      log_dir + "/pact.log"
    end

    def pactfile_write_mode
      if @pactfile_write_mode == :smart
        is_rake_running? ? :overwrite : :update
      else
        @pactfile_write_mode
      end
    end

    private

    def differs
      @differ_registration + DIFFERS
    end

    def self.default_log_dir
      File.expand_path("./log")
    end

    #Would love a better way of determining this! It sure won't work on windows.
    def is_rake_running?
      `ps -ef | grep rake | grep #{Process.ppid} | grep -v 'grep'`.size > 0
    end

    def create_logger
      FileUtils::mkdir_p log_dir
      logger = Logger.new(log_path)
      logger.level = Logger::DEBUG
      logger
    end
  end

  def self.configuration
    @configuration ||= Configuration.default_configuration
  end

  def self.configure
    yield configuration
    FileUtils::mkdir_p configuration.tmp_dir
  end

  def self.clear_configuration
    @configuration = nil
  end

end