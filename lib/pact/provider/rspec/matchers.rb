require 'rspec'
require 'pact/matchers'
require 'pact/provider/matchers/messages'
require 'pact/rspec'
require 'pact/shared/json_differ'

module Pact
  module RSpec
    module Matchers
      module RSpec2Delegator
        # For backwards compatibility with rspec-2
        def method_missing(method, *args, &block)
          if method_name == :failure_message_for_should
            failure_message method, *args, &block
          else
            super
          end
        end
      end

      class MatchTerm
        include Pact::Matchers::Messages
        include RSpec2Delegator

        def initialize expected, differ, diff_formatter, example
          @expected = expected
          @differ = differ
          @diff_formatter = diff_formatter
          @example = example
        end

        def matches? actual
          @actual = actual
          @difference = @differ.call(@expected, @actual)
          unless @difference.empty?
            Pact::RSpec.with_rspec_3 do
              @example.metadata[:pact_diff] = @difference
            end
            Pact::RSpec.with_rspec_2 do
              @example.example.metadata[:pact_diff] = @difference
            end
          end
          @difference.empty?
        end

        def failure_message
          match_term_failure_message @difference, @actual, @diff_formatter, Pact::RSpec.color_enabled?
        end
      end

      def match_term expected, options, example
        MatchTerm.new(expected, options.fetch(:with), options.fetch(:diff_formatter), example)
      end

      class MatchHeader
        include Pact::Matchers
        include Pact::Matchers::Messages
        include RSpec2Delegator

        def initialize header_name, expected
          @header_name = header_name
          @expected = expected
        end

        def matches? actual
          @actual = actual
          diff(@expected, @actual).empty?
        end

        def failure_message
          match_header_failure_message @header_name, @expected, @actual
        end
      end

      def match_header header_name, expected
        MatchHeader.new(header_name, expected)
      end
    end
  end
end
