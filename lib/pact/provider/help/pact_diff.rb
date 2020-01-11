require 'pact/hal/entity'

module Pact
  module Provider
    module Help
      class PactDiff
        class PrintPactDiffError < StandardError; end

        attr_reader :pact_source, :output

        def initialize pact_source
          @pact_source = pact_source
        end

        def self.call pact_source
          new(pact_source).call
        end

        def call
          begin
            header + "\n" + get_diff
          rescue PrintPactDiffError => e
            return e.message
          end
        end

        private

        def header
          "The following changes have been made since the previous distinct version of this pact, and may be responsible for verification failure:\n"
        end

        def get_diff
          begin
            pact_source.hal_entity._link!("pb:diff-previous-distinct").get!(nil, "Accept" => "text/plain").body
          rescue StandardError => e
            raise PrintPactDiffError.new("Tried to retrieve diff with previous pact, but received error #{e.class} #{e.message}.")
          end
        end
      end
    end
  end
end
