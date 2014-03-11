module Pact
  module Matchers
    class PlusMinusDiffDecorator

      def initialize diff
        @diff = diff
      end

      def to_s
        #Active support safe this
        expected = JSON.pretty_generate handle(diff, :expected)
        actual = JSON.pretty_generate handle(diff, :actual)

        RSpec::Expectations::Differ.new.diff_as_string expected, actual
      end

      def handle thing, target
        case thing
        when Hash then copy_hash(thing, target)
        when Array then copy_array(thing, target)
        when Difference then copy_diff(thing, target)
        else copy_object(thing, target)
        end
      end

      private

      def copy_hash hash, target
        hash.keys.each_with_object({}) do | key, new_hash |
          new_hash[key] = handle hash[key], target
        end
      end

      def copy_array array, target
        array.each_index.each_with_object([]) do | index, new_array |
          new_array[index] = handle array[index], target
        end
      end

      def do_nothing

      end

      def copy_diff difference, target
        return target == :actual ? difference.actual : difference.expected
        if target == :actual
          case difference.actual
          when KeyNotFound then do_nothing
          when IndexNotFound then do_nothing
          when UnexpectedKey then difference.actual
          when UnexpectedIndex then difference.actual
          end
        else
          case difference.expected
          when KeyNotFound then difference.expected
          when IndexNotFound then difference.expected
          when UnexpectedKey then do_nothing
          when UnexpectedIndex then do_nothing
          end
        end

      end

      def copy_object object, target
        object
      end

      attr_reader :diff
    end
  end
end