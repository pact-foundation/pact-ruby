require 'rspec'
require 'pact/matchers'
require 'pact/provider/matchers/messages'

RSpec::Matchers.define :match_term do |expected|

  include Pact::Matchers
  include Pact::Matchers::Messages

  match do |actual|
    (@difference = diff(expected, actual)).empty?
  end

  failure_message_for_should do | actual |
    match_term_failure_message @difference, ::RSpec.configuration.color_enabled
  end

end

RSpec::Matchers.define :match_header do |header_name, expected|

  include Pact::Matchers
  include Pact::Matchers::Messages

  match do |actual|
    diff(expected, actual).empty?
  end

  failure_message_for_should do | actual |
    match_header_failure_message header_name, expected, actual
  end

end