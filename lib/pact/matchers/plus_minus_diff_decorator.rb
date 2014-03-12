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

        RSpec::Expectations::Differ.new.diff_as_string actual, expected
      end

      def handle thing, target
        case thing
        when Hash then copy_hash(thing, target)
        when Array then copy_array(thing, target)
        when Difference then copy_diff(thing, target)
        when NoDiffIndicator then copy_no_diff(thing, target)
        else copy_object(thing, target)
        end
      end

      private

      def copy_hash hash, target
        hash.keys.each_with_object({}) do | key, new_hash |
          value = handle hash[key], target
          new_hash[key] = value unless (KeyNotFound === value || UnexpectedKey === value)
        end
      end

      def copy_array array, target
        array.each_index.each_with_object([]) do | index, new_array |
          value = handle array[index], target
          new_array[index] = value unless (UnexpectedIndex === value || IndexNotFound === value)
        end
      end

      def do_nothing
      end

      def copy_no_diff(thing, target)
        thing
      end

      def copy_diff difference, target
        if target == :actual
          difference.actual
        else
          difference.expected
        end
      end

      def copy_object object, target
        object
      end

      attr_reader :diff
    end

    # class NoDiffIndicatorDecorator

    #   def initialize
    #     @no_diff_indicator = NoDiffIndicator.new
    #   end

    #   def to_json options = {}
    #     @no_diff_indicator.to_json + ","
    #   end

    # end
  end
end