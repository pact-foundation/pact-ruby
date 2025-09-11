# frozen_string_literal: true

require_relative "base"

module Pact
  module V2
    module Consumer
      module PactConfig
        class Http < Base
          attr_reader :mock_host, :mock_port, :pact_handle

          def initialize(consumer_name:, provider_name:, opts: {})
            super

            @mock_host = opts[:mock_host] || "127.0.0.1"
            @mock_port = opts[:mock_port] || 0
            @log_level = opts[:log_level] || :info
            @pact_specification = get_pact_specification(opts)
            @pact_handle = init_pact
          end

          def new_interaction(description = nil)
            HttpInteractionBuilder.new(self, description: description)
          end

          def reset_pact
            @pact_handle = init_pact
          end

          def get_pact_specification(opts)
            pact_spec_version = opts[:pact_specification] || "V4"
            unless pact_spec_version.match?(/^v?[1-4](\.\d+){0,2}$/i)
              raise ArgumentError, "Invalid pact specification version format \n Valid versions are 1, 1.1, 2, 3, 4. Default is V4 \n V prefix is optional, and case insensitive"
            end
            pact_spec_version = pact_spec_version.upcase
            pact_spec_version = "V#{pact_spec_version}" unless pact_spec_version.start_with?("V")
            pact_spec_version = pact_spec_version.sub(/(\.0+)+$/, "")
            pact_spec_version = pact_spec_version.tr(".", "_")
            PactFfi::FfiSpecificationVersion["SPECIFICATION_VERSION_#{pact_spec_version.upcase}"]
          end

          def init_pact
            handle = PactFfi.new_pact(consumer_name, provider_name)
            PactFfi.with_specification(handle, @pact_specification)
            PactFfi.with_pact_metadata(handle, "pact-ruby-v2", "pact-ffi", PactFfi.version)

            Pact::V2::Native::Logger.log_to_stdout(@log_level)

            handle
          end
        end
      end
    end
  end
end
