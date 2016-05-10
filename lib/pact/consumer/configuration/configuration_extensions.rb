require 'pact/configuration'
require 'pact/doc/markdown/generator'

module Pact
  module Consumer
    module Configuration

      module ConfigurationExtensions

        DOC_GENERATORS = { markdown: Pact::Doc::Markdown::Generator }

        def doc_dir
          @doc_dir ||= File.expand_path("./doc/pacts")
        end

        def doc_dir= doc_dir
          @doc_dir = doc_dir
        end

        def reports_dir
          @reports_dir ||= default_reports_dir
        end

        def default_reports_dir
          File.expand_path("./reports/pacts")
        end

        def reports_dir= reports_dir
          @reports_dir = reports_dir
        end

        def add_provider_verification &block
          provider_verifications << block
        end

        def provider_verifications
          @provider_verifications ||= []
        end

        def doc_generator= doc_generator
          add_doc_generator doc_generator
        end

        def add_doc_generator doc_generator
          doc_generators << begin
            if DOC_GENERATORS[doc_generator]
              DOC_GENERATORS[doc_generator]
            elsif doc_generator.respond_to?(:call)
              doc_generator
            else
              raise "doc_generator needs to respond to call, or be in the preconfigured list: #{DOC_GENERATORS.keys}"
            end
          end
        end

        def doc_generators
          @doc_generators  ||= []
        end

        def pactfile_write_mode
          @pactfile_write_mode ||= :overwrite
          if @pactfile_write_mode == :smart
            is_rake_running? ? :overwrite : :update
          else
            @pactfile_write_mode
          end
        end

        def pactfile_write_mode= pactfile_write_mode
          @pactfile_write_mode = pactfile_write_mode
        end

        def pactfile_write_order
          @pactfile_write_order ||= :chronological #or :alphabetical
        end

        def pactfile_write_order= pactfile_write_order
          @pactfile_write_order = pactfile_write_order.to_sym
        end

        private

        #Would love a better way of determining this! It sure won't work on windows.
        def is_rake_running?
          `ps -ef | grep rake | grep #{Process.ppid} | grep -v 'grep'`.size > 0
        end
      end
    end
  end
end
