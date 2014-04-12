module Pact
  module Matchers

    class PlusMinusDiffDecorator

      def initialize diff, options = {}
        @diff = diff
      end

      def self.call diff, options = {}
        new(diff, options).call
      end

      def call
        to_s
      end

      def to_s
        expected = generate_string(diff, :expected)
        actual = generate_string(diff, :actual)

        RSpec::Expectations::Differ.new.diff_as_string actual, expected
      end

      private

      def handle thing, target
        case thing
        when Hash then copy_hash(thing, target)
        when Array then copy_array(thing, target)
        when Difference then copy_diff(thing, target)
        when NoDiffIndicator then copy_no_diff(thing, target)
        else copy_object(thing, target)
        end
      end

      def generate_string diff, target
        comparable = handle(diff, target)
        begin
          # Can't think of an elegant way to check if we can pretty generate other than to try it and maybe fail
          JSON.pretty_generate(comparable)
        rescue JSON::GeneratorError
          comparable.to_s
        end
      end

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

      def copy_no_diff(thing, target)
        thing
      end

      def copy_diff difference, target
        if target == :actual
          copy_object difference.actual, target
        else
          copy_object difference.expected, target
        end
      end

      def copy_object object, target
        if Regexp === object
          RegexpDecorator.new(object)
        else
          object
        end
      end

      class RegexpDecorator

        def initialize regexp
          @regexp = regexp
        end

        def to_json options={}
          @regexp.inspect
        end

        def as_json
          @regexp.inspect
        end
      end

      attr_reader :diff
    end

  end
end