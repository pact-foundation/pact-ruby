# Should stop monkey patching this an write a function

module Matching
  def both_diffable expected, actual, key
    expected[key].respond_to?(:diff_with_actual) && actual[key].respond_to?(:diff_with_actual)
  end

  def do_not_match expected, actual, key
    # Handle 'expected' being a Pact::Term that may _match_ a string 'actual', without _equaling_ it.
    expected[key] != actual[key] && !(do_match(expected[key], actual[key]))
  end

  def do_match expected, actual
    if expected.is_a?(String) && actual.is_a?(String)
      expected == actual
    else
      #Could be a Term or a regex - Term returns true, regex returns MatchData or nil
      expected.respond_to?(:match) && !actual.nil? && expected.match(actual)
    end
  end
end

class String
  def diff_with_actual actual
    if self != actual
      {:expected => self, :actual => actual}
    else
      {}
    end
  end
end

class Numeric
  def diff_with_actual actual
    if self != actual
      {:expected => self, :actual => actual}
    else
      {}
    end
  end
end

class Hash
  include Matching
  def diff_with_actual(actual)
    expected = self
    if actual.is_a? Hash
      expected.keys.inject({}) do |diff, key|
        if do_not_match expected, actual, key
          if expected[key].respond_to?(:diff_with_actual)
            key_diff = expected[key].diff_with_actual(actual[key])
            diff[key] = key_diff unless key_diff.empty? #Not sure why we need this check here?
          else
            diff[key] = {
              expected: expected[key],
              actual: actual[key]
            }
          end
        end
        diff
      end
    else
      {expected: expected, actual: actual}
    end
  end

  private


end

class Array
  include Matching

  def diff_with_actual actual
    expected = self
    if actual.is_a? Array
      if expected.length == actual.length
        expected.each_with_index do | item, index |
          if do_not_match expected, actual, index
            return {expected: expected, actual: actual}
          end
        end
        {}
      else
        {expected: expected, actual: actual}
      end
    else
      {expected: expected, actual: actual}
    end
  end
end