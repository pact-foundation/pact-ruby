require 'rspec'
require 'pact/matchers'
require 'term/ansicolor'

RSpec::Matchers.define :match_term do |expected|

  include Pact::Matchers

  match do |actual|
    (@difference = diff(expected, actual)).empty?
  end

  failure_message_for_should do | actual |

    # RSpec wraps each line in the failure message with failure_color, turning it red.
    # To ensure the lines in the diff that should be white, stay white, put an
    # ANSI reset at the start of each line.

    message = Pact.configuration.diff_formatter.call(@difference)

    if ::RSpec.configuration.color_enabled
      message.split("\n").collect{ |line| ::Term::ANSIColor.reset + line }.join("\n")
    else
      message
    end
  end

end