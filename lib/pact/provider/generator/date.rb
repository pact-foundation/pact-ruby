require 'date'

module Pact
  module Provider
    module Generator
      # Date provides the time generator which will give the current date in the defined format
      class Date
        def can_generate?(hash)
          hash.key?('type') && hash['type'] == type
        end

        def call(hash, _params = nil, _example_value = nil)
          format = hash['format'] || default_format
          ::Time.now.strftime(convert_from_java_simple_date_format(format))
        end

        def type
          'Date'
        end

        def default_format
          'yyyy-MM-dd'
        end

        # Format for the pact specficiation should be the Java DateTimeFormmater
        # This tries to convert to something Ruby can format.
        def convert_from_java_simple_date_format(format)
          # Year
          format.sub!(/(?<!%)y{4,}/, '%Y')
          format.sub!(/(?<!%)y{1,}/, '%y')

          # Month
          format.sub!(/(?<!%)M{4,}/, '%B')
          format.sub!(/(?<!%)M{3}/, '%b')
          format.sub!(/(?<!%)M{1,2}/, '%m')

          # Week
          format.sub!(/(?<!%)M{1,}/, '%W')

          # Day
          format.sub!(/(?<!%)D{1,}/, '%j')
          format.sub!(/(?<!%)d{1,}/, '%d')
          format.sub!(/(?<!%)E{4,}/, '%A')
          format.sub!(/(?<!%)D{1,}/, '%a')
          format.sub!(/(?<!%)u{1,}/, '%u')

          # Time
          format.sub!(/(?<!%)a{1,}/, '%p')
          format.sub!(/(?<!%)k{1,}/, '%H')
          format.sub!(/(?<!%)n{1,}/, '%M')
          format.sub!(/(?<!%)s{1,}/, '%S')
          format.sub!(/(?<!%)S{1,}/, '%L')

          # Timezone
          format.sub!(/(?<!%)z{1,}/, '%z')
          format.sub!(/(?<!%)Z{1,}/, '%z')
          format.sub!(/(?<!%)X{1,}/, '%Z')

          format
        end
      end
    end
  end
end
