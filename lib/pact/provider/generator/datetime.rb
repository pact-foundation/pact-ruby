require 'date'

module Pact
  module Provider
    module Generator
      # DateTime provides the time generator which will give the current date time in the defined format
      class DateTime < Date
        def type
          'DateTime'
        end

        def default_format
          'yyyy-MM-dd HH:mm'
        end
      end
    end
  end
end
