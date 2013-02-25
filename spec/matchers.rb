RSpec::Matchers.define :have_specification do |expected|
  match do |actual|
    actual.specification == expected
  end
end
