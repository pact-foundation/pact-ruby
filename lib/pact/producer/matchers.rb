require 'pact/term'
require 'awesome_print'
require 'pact/matchers'
require 'awesome_print'

RSpec::Matchers.define :match_term do |expected|
  include Pact::Matchers

  match do |actual|
    if (difference = diff(expected, actual)).any?
      @message = difference
      false
    else
      true
    end
  end

  failure_message_for_should do | actual |
    @message.ai
  end

end