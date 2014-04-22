module Pact
  module Matchers
    class ListDiffFormatter

      attr_reader :diff

      def initialize diff, options = {}
        @diff = diff
      end

      def self.call diff, options = {}
        new(diff, options).call
      end

      def to_hash
        diff
      end

      def call
        to_s
      end

      def to_s
        diff_descriptions(diff).join("\n")
      end

      def diff_descriptions obj, path = [], descriptions = []
        case obj
        when Hash then handle_hash obj, path, descriptions
        when Array then handle_array obj, path, descriptions
        when Difference then handle_difference obj, path, descriptions
        when TypeDifference then handle_mismatched_type obj, path, descriptions
        when RegexpDifference then handle_mismatched_regexp obj, path, descriptions
        when NoDiffIndicator then nil
        else
          raise "Invalid diff, expected Hash, Array, NoDiffIndicator or Difference, found #{obj.class}"
        end
        descriptions
      end

      def handle_hash hash, path, descriptions
        hash.each_pair do | key, value |
          diff_descriptions value, path + [key.inspect], descriptions
        end
      end

      def handle_array array, path, descriptions
        array.each_with_index do | obj, index |
          diff_descriptions obj, path + [index], descriptions
        end
      end

      def handle_difference difference, path, descriptions
        case difference.expected
        when Pact::UnexpectedKey then handle_unexpected_key(difference, path, descriptions)
        when Pact::UnexpectedIndex then handle_unexpected_index(difference, path, descriptions)
        else
          case difference.actual
          when Pact::KeyNotFound then handle_key_not_found(difference, path, descriptions)
          when Pact::IndexNotFound then handle_index_not_found(difference, path, descriptions)
          else
            handle_mismatched_value(difference, path, descriptions)
          end
        end
      end

      def handle_unexpected_index difference, path, descriptions
        descriptions << "\tAt:\n\t\t#{path_to_s(path)}\n\tArray contained unexpected item:\n\t\t#{difference.actual.ai}"
      end

      def handle_mismatched_value difference, path, descriptions
        descriptions << "\tAt:\n\t\t#{path_to_s(path)}\n\tExpected:\n\t\t#{difference.expected.ai}\n\tActual:\n\t\t#{difference.actual.ai}"
      end

      def handle_mismatched_regexp difference, path, descriptions
        descriptions << "\tAt:\n\t\t#{path_to_s(path)}\n\tExpected to match:\n\t\t#{difference.expected.inspect}\n\tActual:\n\t\t#{difference.actual.ai}"
      end

      def handle_mismatched_type difference, path, descriptions
        descriptions << "\tAt:\n\t\t#{path_to_s(path)}\n\tExpected type:\n\t\t#{difference.expected}\n\tActual type:\n\t\t#{difference.actual}"
      end

      def handle_index_not_found difference, path, descriptions
        descriptions << "\tAt:\n\t\t#{path_to_s(path)}\n\tMissing index with value:\n\t\t#{difference.expected.ai}"
      end

      def handle_key_not_found difference, path, descriptions
        descriptions << "\tAt:\n\t\t#{path_to_s(path)}\n\tMissing key with value:\n\t\t#{difference.expected.ai}"
      end

      def handle_unexpected_key difference, path, descriptions
        descriptions << "\tAt:\n\t\t#{path_to_s(path)}\n\tHash contained unexpected key with value:\n\t\t#{difference.actual.ai}"
      end

      def path_to_s path
        "[" + path.join("][") + "]"
      end

    end
  end
end