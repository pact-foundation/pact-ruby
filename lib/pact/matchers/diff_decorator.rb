module Pact
  module Matchers
    class DiffDecorator

      attr_reader :diff

      def initialize diff
        @diff = diff
      end

      def to_hash
        diff.to
      end

      def to_s
        diff_descriptions(diff).join("\n").tap{ | it | puts it}
      end

      def diff_descriptions obj, path = [], descriptions = []
        case obj
        when Hash then handle_hash obj, path, descriptions
        when Array then handle_array obj, path, descriptions
        when Difference then handle_difference obj, path, descriptions
        when NoDiffIndicator then nil
        else
          raise "Invalid diff, expected Hash, Array, NoDiffIndicator or Difference, found #{obj}"
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
          diff_descriptions obj, path + [ArrayIndex.new(index)], descriptions
        end
      end

      def handle_difference difference, path, descriptions

        case difference.actual
        when Pact::KeyNotFound then handle_key_not_found(difference, path, descriptions)
        when Pact::IndexNotFound then handle_index_not_found(difference, path, descriptions)
        else
          case difference.expected
          when Pact::UnexpectedKey then handle_unexpected_key(difference, path, descriptions)
          when Pact::UnexpectedIndex then handle_unexpected_index(difference, path, descriptions)
          else
            handle_mismatched_value(difference, path, descriptions)
          end
        end
      end

      def handle_unexpected_index difference, path, descriptions
        descriptions << "\tIn array at:\n\t\t#{path_to_s(path)}\n\tArray contained unexpected item at index #{path.last}:\n\t\t#{tabify(difference.actual.ai, 2)}"
      end

      def handle_mismatched_value difference, path, descriptions
        if path.last.is_a?(ArrayIndex)
          descriptions << "\tIn array at:\n\t\t#{path_to_s(path)}\n\tExpected index #{path.last} to have value:\n\t\t#{difference.expected.ai}\n\tActual value:\n\t\t#{tabify(difference.actual.ai, 2)}"
        else
          descriptions << "\tIn hash at:\n\t\t#{path_to_s(path)}\n\tExpected key #{path.last} to have value:\n\t\t#{difference.expected.ai}\n\tActual value:\n\t\t#{tabify(difference.actual.ai, 2)}"
        end
      end

      def handle_index_not_found difference, path, descriptions
        descriptions << "\tIn array at:\n\t\t#{path_to_s(path)}\n\tMissing item at index #{path.last} with value:\n\t\t#{tabify(difference.expected.ai, 2)}"
      end

      def handle_key_not_found difference, path, descriptions
        descriptions << "\tIn hash at:\n\t\t#{path_to_s(path)}\n\tMissing key #{path.last} with value:\n\t\t#{tabify(difference.expected.ai, 2)}"
      end

      def handle_unexpected_key difference, path, descriptions
        descriptions << "\tIn hash at:\n\t\t#{path_to_s(path)}\n\tHash contained unexpected key #{path.last} with value:\n\t\t#{tabify(difference.actual.ai, 2)}"
      end

      def path_to_s path
        "[" + path[0..-2].join("][") + "]"
      end

      def tabify string, tab_count
        tabs = "\t" * tab_count
        string.gsub(/\n/, "\n#{tabs}")
      end

      class ArrayIndex
        attr_reader :index
        def initialize index
          @index = index
        end

        def inspect
          index.inspect
        end

        def to_s
          index.to_s
        end
      end

    end
  end
end