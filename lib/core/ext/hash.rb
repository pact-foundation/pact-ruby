class Hash
  def diff_with_actual(actual)
    expected = self
    expected.keys.inject({}) do |diff, key|
      # Handle 'expected' being a Pact::Term that may _match_ a string 'actual', without _equaling_ it.
      if expected[key] != actual[key] && !(expected[key].respond_to?(:match) && !actual[key].nil? && expected[key].match(actual[key]))
        if expected[key].respond_to?(:diff_with_actual) && actual[key].respond_to?(:diff_with_actual)
          key_diff = expected[key].diff_with_actual(actual[key])
          diff[key] = key_diff unless key_diff.empty?
        else
          diff[key] = {
            expected: expected[key],
            actual: actual[key]
          }
        end
      end
      diff
    end
  end
end
