require 'awesome_print'
require 'pact/term'
require 'pact/something_like'
require 'pact/shared/null_expectation'
require 'pact/shared/key_not_found'
require 'pact/matchers/unexpected_key'
require 'pact/matchers/unexpected_index'
require 'pact/matchers/index_not_found'
require 'pact/matchers/difference'

module Pact
  module Matchers

    class NoDiffIndicator

      def to_json options = {}
        to_s
      end

      def to_s
        'no difference here!'
      end

      def == other
        other.is_a? NoDiffIndicator
      end
    end

    NO_DIFF_INDICATOR = NoDiffIndicator.new
    #UnexpectedKey.new = '<key not to be present>'
    DEFAULT_OPTIONS = {allow_unexpected_keys: true, structure: false}.freeze

    def diff expected, actual, opts = {}
      options = DEFAULT_OPTIONS.merge(opts)
      case expected
      when Hash then hash_diff(expected, actual, options)
      when Array then array_diff(expected, actual, options)
      when Pact::Term then diff(expected.matcher, actual, options)
      when Regexp then regexp_diff(expected, actual, options)
      when Pact::SomethingLike then diff(expected.contents, actual, options.merge(:structure => true))
      else object_diff(expected, actual, options)
      end
    end

    def structure_diff expected, actual
      diff expected, actual, {structure: true}
    end

    def regexp_diff regexp, actual, options
      if actual.is_a?(String) && regexp.match(actual)
        {}
      else
        Difference.new regexp, actual
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
        if (item_diff = diff(expected_item, actual_item, options)).any?
          diff_found = true
          difference << item_diff
        else
          difference << NO_DIFF_INDICATOR
        end
      end
      diff_found ? difference : {}
    end

    def actual_hash_diff expected, actual, options
      difference = expected.keys.inject({}) do |diff, key|
        if (diff_at_key = diff(expected[key], actual.fetch(key, Pact::KeyNotFound.new), options)).any?
          diff[key] = diff_at_key
        end
        diff
      end
      difference.merge(check_for_unexpected_keys(expected, actual, options))
    end

    def check_for_unexpected_keys expected, actual, options
      if options[:allow_unexpected_keys]
        {}
      else
        (actual.keys - expected.keys).inject({}) do | diff, key |
          diff[key] = Difference.new(UnexpectedKey.new, actual[key])
          diff
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

    def class_diff expected, actual
      if classes_match? expected, actual
        {}
      else
        Difference.new structure_diff_expected_display(expected), structure_diff_actual_display(actual)
      end
    end

    def structure_diff_actual_display actual
      (actual.nil? || actual.is_a?(KeyNotFound) ) ? actual : {:class => actual.class, :value => actual }
    end

    def structure_diff_expected_display expected
      (expected.nil?) ? expected : {:class => expected.class, eg: expected}
    end

    def classes_match? expected, actual
      #There must be a more elegant way to do this
      expected.class == actual.class ||
        (expected.is_a?(TrueClass) && actual.is_a?(FalseClass)) ||
          (expected.is_a?(FalseClass) && actual.is_a?(TrueClass))
    end

    def object_diff expected, actual, options
      return class_diff(expected, actual) if options[:structure]
      if expected != actual
        Difference.new expected, actual
      else
        {}
      end
    end
  end
end
