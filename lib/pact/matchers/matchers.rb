module Pact
  module Matchers

    NO_DIFF_INDICATOR = 'no difference here!'

    def diff expected, actual
      case expected
      when Hash then hash_diff(expected, actual)
      when Array then array_diff(expected, actual)
      when Pact::Term then diff(expected.matcher, actual)
      when Regexp then regexp_diff(expected, actual)
      else object_diff(expected, actual)
      end
    end

    def regexp_diff regexp, actual
      if actual != nil && regexp.match(actual)
        {}
      else
        {expected: regexp, actual: actual}
      end
    end

    def array_diff expected, actual
      if actual.is_a? Array
        if expected.length == actual.length
          difference = []
          diff_found = false
          expected.each_with_index do | item, index|
            if (item_diff = diff(item, actual[index])).any?
              diff_found = true
              difference << item_diff
            else
              difference << NO_DIFF_INDICATOR
            end
          end
          diff_found ? difference : {}
        else
          {expected: expected, actual: actual}
        end
      else
        {expected: expected, actual: actual}
      end
    end

    def hash_diff expected, actual
      if actual.is_a? Hash
        expected.keys.inject({}) do |diff, key|
          if (diff_at_key = diff(expected[key], actual[key])).any?
            diff[key] = diff_at_key
          end
          diff
        end
      else
        {expected: expected, actual: actual}
      end
    end

    def object_diff expected, actual
      if expected != actual
        {:expected => expected, :actual => actual}
      else
        {}
      end
    end
  end
end
