require 'date'

module Pact
  module Provider
    module Generator
      # Time provides the time generator which will give the current time in the defined format
      class Time < Date
        def type
          'Time'
        end

        def default_format
          'HH:mm'
        end
      end
    end
  end
end
