require 'awesome_print'
require 'pact/term'
require 'pact/something_like'
require 'pact/shared/null_expectation'
require 'pact/shared/key_not_found'
require 'pact/matchers/unexpected_key'
require 'pact/matchers/unexpected_index'
require 'pact/matchers/index_not_found'
require 'pact/matchers/difference'
require 'pact/matchers/regexp_difference'
require 'pact/matchers/type_difference'
require 'pact/matchers/expected_type'
require 'pact/matchers/actual_type'
require 'pact/matchers/no_diff_indicator'

module Pact
  module Matchers

    NO_DIFF_INDICATOR = NoDiffIndicator.new
    DEFAULT_OPTIONS = {allow_unexpected_keys: true, type: false}.freeze

    def diff expected, actual, opts = {}
      calculate_diff(Pact::Term.unpack_regexps(expected), actual, DEFAULT_OPTIONS.merge(opts))
    end

    def type_diff expected, actual, opts = {}
      calculate_diff Pact::Term.unpack_regexps(expected), actual, DEFAULT_OPTIONS.merge(opts).merge(type: true)
    end

    private

    def calculate_diff expected, actual, opts = {}
      options = DEFAULT_OPTIONS.merge(opts)
      case expected
      when Hash then hash_diff(expected, actual, options)
      when Array then array_diff(expected, actual, options)
      when Regexp then regexp_diff(expected, actual, options)
      when Pact::SomethingLike then calculate_diff(expected.contents, actual, options.merge(:type => true))
      else object_diff(expected, actual, options)
      end
    end

    alias_method :structure_diff, :type_diff # Backwards compatibility

    def regexp_diff regexp, actual, options
      if actual.is_a?(String) && regexp.match(actual)
        {}
      else
        RegexpDifference.new regexp, actual
      end
    end

    def array_diff expected, actual, options
      if actual.is_a? Array
        actual_array_diff expected, actual, options
      else
        Difference.new expected, actual
      end
    end

    def actual_array_diff expected, actual, options
      difference = []
      diff_found = false
      length = [expected.length, actual.length].max
      length.times do | index|
        expected_item = expected.fetch(index, Pact::UnexpectedIndex.new)
        actual_item = actual.fetch(index, Pact::IndexNotFound.new)
        if (item_diff = calculate_diff(expected_item, actual_item, options)).any?
          diff_found = true
          difference << item_diff
        else
          difference << NO_DIFF_INDICATOR
        end
      end
      diff_found ? difference : {}
    end

    def actual_hash_diff expected, actual, options
      difference = expected.keys.inject({}) do |calculate_diff, key|
        if (diff_at_key = calculate_diff(expected[key], actual.fetch(key, Pact::KeyNotFound.new), options)).any?
          calculate_diff[key] = diff_at_key
        end
        calculate_diff
      end
      difference.merge(check_for_unexpected_keys(expected, actual, options))
    end

    def check_for_unexpected_keys expected, actual, options
      if options[:allow_unexpected_keys]
        {}
      else
        (actual.keys - expected.keys).inject({}) do | calculate_diff, key |
          calculate_diff[key] = Difference.new(UnexpectedKey.new, actual[key])
          calculate_diff
        end
      end
    end

    def hash_diff expected, actual, options
      if actual.is_a? Hash
        actual_hash_diff expected, actual, options
      else
        Difference.new expected, actual
      end
    end

    def type_difference expected, actual
      if types_match? expected, actual
        {}
      else
        TypeDifference.new type_diff_expected_display(expected), type_diff_actual_display(actual)
      end
    end

    def type_diff_actual_display actual
      actual.is_a?(KeyNotFound) ?  actual : ActualType.new(actual)
    end

    def type_diff_expected_display expected
      ExpectedType.new(expected)
    end

    def types_match? expected, actual
      #There must be a more elegant way to do this
      expected.class == actual.class ||
        (expected.is_a?(TrueClass) && actual.is_a?(FalseClass)) ||
          (expected.is_a?(FalseClass) && actual.is_a?(TrueClass))
    end

    def object_diff expected, actual, options
      return type_difference(expected, actual) if options[:type]
      if expected != actual
        Difference.new expected, actual
      else
        {}
      end
    end
  end
end
