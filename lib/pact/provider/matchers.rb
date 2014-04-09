require 'pact/term'
require 'pact/consumer_contract/active_support_support'
require 'awesome_print'
require 'pact/matchers'
require 'awesome_print'
require 'rspec'

RSpec::Matchers.define :match_term do |expected|
  include Pact::Matchers
  include Pact::ActiveSupportSupport

  match do |actual|
    if (difference = diff(expected, actual)).any?
      @message = difference
      false
    else
      true
    end
  end

  failure_message_for_should do | actual |
    fix_json_formatting @message.to_json
  end

end