require 'pact/term'
# TODO: Pull the matcher code out into it's own non-RSpec class

RSpec::Matchers.define :match_term do |expected|

  def matching? actual, expected, desc = nil, parent = nil
    mismatch = {actual: actual, expected: expected, desc: desc, parent: parent}
    case expected
    when *[Array, Hash, Regexp]
      send("match_#{expected.class.name.downcase}", actual, expected, mismatch)
    when Pact::Term
      match_term actual, expected
    else
      match_object actual, expected, mismatch
    end
    true
  end

  def match_object actual, expected, mismatch
    throw :mismatch, mismatch.merge({reason: 'Objects not equal.'}) unless actual == expected
  end

  def match_regexp actual, expected, mismatch
    throw :mismatch, mismatch.merge({reason: 'Regular expression match failed.'}) unless actual =~ expected
  end

  def match_term actual, expected
    matching? actual, expected.matcher
  end

  def match_hash actual, expected, mismatch
    if actual.is_a?(Hash)
      expected.each do |key, value|
        matching? actual[key], value, "key '#{key}'", actual
      end

      if expected.keys.size == 0
        $stderr.puts "You have expected an empty hash - be aware that this will match any hash, empty or not."
      end

    else
      throw :mismatch, mismatch.merge({reason: "Expected #{actual.class.name} to be a Hash."})
    end
  end

  def match_array actual, expected, mismatch
    if actual.is_a?(Array)
      expected.each_with_index do |value, index|
        matching? actual[index], value, "index #{index}", actual
      end
      if actual.size != expected.size
        throw :mismatch, mismatch.merge({reason: "Expected array length of #{actual.size} to be #{expected.size}."})
      end
    else
      throw :mismatch, mismatch.merge({reason: "Expected #{actual.class.name} to be an Array."})
    end
  end


  match do |actual|
    @message = catch(:mismatch) do
      matching? actual, expected
    end
    @message == true
  end

  def mismatch_message
    actual = @message[:actual].nil? ? 'nil' : "\"#{@message[:actual]}\""
    expected = @message[:expected].nil? ? 'nil' : "\"#{@message[:expected]}\""
    message = " Expected\n#{actual}\n to match\n#{expected}"
    message << "\n at #{@message[:desc]}" if @message[:desc]
    message << " of #{@message[:parent]}" if @message[:parent]
    message << ".\nReason: #{@message[:reason]}"
    message
  end

  failure_message_for_should do | actual |
    mismatch_message
  end

end