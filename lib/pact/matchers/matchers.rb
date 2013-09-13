require 'awesome_print'
require 'pact/term'

module Pact
  module Matchers

    NO_DIFF_INDICATOR = 'no difference here!'
    UNEXPECTED_KEY = '<key not to be present>'
    DEFAULT_OPTIONS = {allow_unexpected_keys: true, structure: false}.freeze

    class KeyNotFound
      def == other
        other.is_a? KeyNotFound
      end

      def eql? other
        self == other
      end

      def to_s
        "<key not found>"
      end

      def to_json options = {}
        to_s
      end
    end

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
      if actual != nil && regexp.match(actual)
        {}
      else
        {expected: regexp, actual: actual}
      end
    end

    def array_diff expected, actual, options
      if actual.is_a? Array
        if expected.length == actual.length
          actual_array_diff expected, actual, options
        else
          {expected: expected, actual: actual}
        end
      else
        {expected: expected, actual: actual}
      end
    end

    def actual_array_diff expected, actual, options
      difference = []
      diff_found = false
      expected.each_with_index do | item, index|
        if (item_diff = diff(item, actual.fetch(index, KeyNotFound.new), options)).any?
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
        if (diff_at_key = diff(expected[key], actual.fetch(key, KeyNotFound.new), options)).any?
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
          diff[key] = {:expected => UNEXPECTED_KEY, :actual => actual[key]}
          diff
        end
      end
    end

    def hash_diff expected, actual, options
      if actual.is_a? Hash
        actual_hash_diff expected, actual, options
      else
        {expected: expected, actual: actual}
      end
    end

    def class_diff expected, actual
      if classes_match? expected, actual
        {}
      else
        {:expected => structure_diff_expected_display(expected), :actual => structure_diff_actual_display(actual)}
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
        {:expected => expected, :actual => actual}
      else
        {}
      end
    end
  end
end
