require 'awesome_print'
require 'pact/term'

module Pact
  module Matchers

    NO_DIFF_INDICATOR = 'no difference here!'

    def diff expected, actual, options = {}
      case expected
      when Hash then hash_diff(expected, actual, options)
      when Array then array_diff(expected, actual, options)
      when Pact::Term then diff(expected.matcher, actual, options)
      when Regexp then regexp_diff(expected, actual, options)
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
        if (item_diff = diff(item, actual[index], options)).any?
          diff_found = true
          difference << item_diff
        else
          difference << NO_DIFF_INDICATOR
        end
      end
      diff_found ? difference : {}
    end

    def actual_hash_diff expected, actual, options
      expected.keys.inject({}) do |diff, key|
        if (diff_at_key = diff(expected[key], actual[key], options)).any?
          diff[key] = diff_at_key
        end
        diff
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
      if expected.class != actual.class
        actual_display = actual.nil? ? nil : {:class => actual.class, :value => actual }
        expected_display = expected.nil? ? nil : {:class => expected.class, eg: expected}
        {:expected => expected_display, :actual => actual_display}
      else
        {}
      end
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
