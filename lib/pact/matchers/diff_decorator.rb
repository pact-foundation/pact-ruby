module Pact
  module Matchers
    class DiffDecorator

      attr_reader :diff

      def initialize diff
        @diff = diff
      end

      def to_hash
        diff
      end

      def to_s
        description(diff).join("\n")
      end

      def description obj, path = [], messages = []
        case obj
        when Hash then handle_hash obj, path, messages
        when Array then handle_array obj, path, messages
        when Difference then handle_difference obj, path, messages
        when NoDiffIndicator then nil
        else
          raise "Invalid diff, expected Hash, Array or Difference, found #{obj}"
        end
        messages
      end

      def handle_hash hash, path, messages
        hash.each_pair do | key, value |
          description value, path + [key.inspect], messages
        end
      end

      def handle_array array, path, messages
        array.each_with_index do | obj, index |
          description obj, path + [index], messages
        end
      end

      def handle_difference difference, path, messages

        case difference.actual
        when Pact::KeyNotFound then handle_key_not_found(difference, path, messages)
        when Pact::IndexNotFound then handle_index_not_found(difference, path, messages)
        else
          case difference.expected
          when Pact::UnexpectedKey then handle_unexpected_key(difference, path, messages)
          when Pact::UnexpectedIndex then handle_unexpected_index(difference, path, messages)
          else
            handle_mismatched_value(difference, path, messages)
          end
        end
      end

      def handle_unexpected_index difference, path, messages
        messages << "At #{path_to_s(path)}\nArray contained unexpected item: #{difference.actual.ai}"
      end

      def handle_mismatched_value difference, path, messages
        messages << "At #{path_to_s(path)}\nExpected: #{difference.expected.ai}\nActual: #{difference.actual.ai}"
      end

      def handle_index_not_found difference, path, messages
        messages << "At #{path_to_s(path)}\nMissing: #{difference.expected.ai}"
      end

      def handle_key_not_found difference, path, messages
        messages << "At #{path_to_s(path)}\nMissing: #{difference.expected.ai}"
      end

      def handle_unexpected_key difference, path, messages
        messages << "At #{path_to_s(path)}\nHash contained unexpected key with value: #{difference.actual.ai}"
      end

      def path_to_s path
        "[" + path.join("][") + "]"
      end

    end
  end
end