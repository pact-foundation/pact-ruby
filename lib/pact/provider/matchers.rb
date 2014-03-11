require 'pact/term'
require 'awesome_print'
require 'pact/matchers'
require 'awesome_print'
require 'rspec'
require 'pact/matchers/nested_json_diff_decorator'
require 'pact/matchers/diff_decorator'

RSpec::Matchers.define :match_term do |expected|
  include Pact::Matchers


  match do |actual|
    if (difference = diff(expected, actual)).any?
      @diff_decorator = Pact::Matchers::NestedJsonDiffDecorator.new(difference)
      false
    else
      true
    end
  end

  failure_message_for_should do | actual |
    @diff_decorator.to_s
  end

end