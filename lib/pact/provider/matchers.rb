require 'pact/term'
require 'awesome_print'
require 'pact/matchers'
require 'awesome_print'
require 'rspec'

RSpec::Matchers.define :match_term do |expected|
  include Pact::Matchers

  match do |actual|
    (@difference = diff(expected, actual)).empty?
  end

  failure_message_for_should do | actual |
    Pact.configuration.diff_formatter.call(@difference)
  end

end