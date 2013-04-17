class Hash
  def diff_with_actual(expected)
    actual = self
    (actual.keys | expected.keys).inject({}) do |diff, key|
      if actual[key] != expected[key]
        if actual[key].respond_to?(:diff_with_actual) && expected[key].respond_to?(:diff_with_actual)
          diff[key] = actual[key].diff_with_actual(expected[key])
        else
          diff[key] = {
            expected: actual[key],
            actual: expected[key]
          }
        end
      end
      diff
    end
  end
end
