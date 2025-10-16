# frozen_string_literal: true

module Pact
  module V2
    module Generators
      module Base
        def as_basic
          raise NotImplementedError, "Subclasses must implement the as_basic method"
        end
      end

      class RandomIntGenerator
        include Base

        def initialize(min:, max:)
          @min = min
          @max = max
        end

        def as_basic
          {
            "pact:matcher:type" => "integer",
            "pact:generator:type" => "RandomInt",
            "min" => @min,
            "max" => @max,
            "value" => rand(@min..@max)
          }
        end
      end

      class RandomDecimalGenerator
        include Base

        def initialize(digits:)
          @digits = digits
        end

        def as_basic
          {
            'pact:matcher:type' => 'decimal',
            "pact:generator:type" => "RandomDecimal",
            "digits" => @digits,
            "value" => rand.round(@digits)
          }
        end
      end

      class RandomHexadecimalGenerator
        include Base

        def initialize(digits:)
          @digits = digits
        end

        def as_basic
          {
            "pact:matcher:type" => "decimal",
            "pact:generator:type" => "RandomHexadecimal",
            "digits" => @digits,
            "value" => SecureRandom.hex((@digits / 2.0).ceil)[0...@digits]
          }
        end
      end

      class RandomStringGenerator
        include Base

        def initialize(size:, example: nil)
          @size = size
          @example = example
        end

        def as_basic
          {
            "pact:matcher:type" => "type",
            "pact:generator:type" => "RandomString",
            "size" => @size,
            "value" => @example || SecureRandom.alphanumeric(@size)
          }
        end
      end

      class UuidGenerator
        include Base

    
        def initialize(example: nil)
          @example = example
          @regexStr = '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}';
          if @example
            regex = Regexp.new("^#{@regexStr}$")
            unless @example.match?(regex)
              raise ArgumentError, "regex: Example value '#{@example}' does not match the UUID regular expression '#{@regexStr}'"
            end
          end
        end

        def as_basic
          {
            "pact:matcher:type" => "regex",
            "pact:generator:type" => "Uuid",
            "regex" => @regexStr,
            "value" => @example || SecureRandom.uuid
          }
        end
      end

      class DateGenerator
        include Base

        def initialize(format: nil, example: nil)
          @format = format || default_format
          @example = example || Time.now.strftime(convert_from_java_simple_date_format(@format))
        end

        def as_basic
          h = { "pact:generator:type" => type }
          h["pact:matcher:type"] = matcher_type
          h["format"] = @format if @format
          h["value"] = @example
          h
        end

        def type
          'Date'
        end

        def matcher_type
          'date'
        end

        def default_format
          'yyyy-MM-dd'
        end

        # Converts Java SimpleDateFormat to Ruby strftime format
        def convert_from_java_simple_date_format(format)
          f = format.dup
          # Year
          f.gsub!(/(?<!%)y{4,}/, '%Y')
          f.gsub!(/(?<!%)y{1,3}/, '%y')
          # Month
          f.gsub!(/(?<!%)M{4,}/, '%B')
          f.gsub!(/(?<!%)M{3}/, '%b')
          f.gsub!(/(?<!%)M{1,2}/, '%m')
          # Week
          f.gsub!(/(?<!%)w{1,}/, '%W')
          # Day
          f.gsub!(/(?<!%)D{1,}/, '%j')
          f.gsub!(/(?<!%)d{1,}/, '%d')
          f.gsub!(/(?<!%)E{4,}/, '%A')
          f.gsub!(/(?<!%)E{1,3}/, '%a')
          f.gsub!(/(?<!%)u{1,}/, '%u')
          # Time
          f.gsub!(/(?<!%)a{1,}/, '%p')
          f.gsub!(/(?<!%)k{1,}/, '%H')
          f.gsub!(/(?<!%)n{1,}/, '%M')
          f.gsub!(/(?<!%)s{1,}/, '%S')
          f.gsub!(/(?<!%)S{1,}/, '%L')
          # Timezone
          f.gsub!(/(?<!%)z{1,}/, '%z')
          f.gsub!(/(?<!%)Z{1,}/, '%z')
          f.gsub!(/(?<!%)X{1,}/, '%Z')
          # Java 'H' (hour in day, 0-23) to Ruby '%H'
          f.gsub!(/(?<!%)H{2}/, '%H')
          f.gsub!(/(?<!%)H{1}/, '%k')
          # Java 'm' (minute in hour) to Ruby '%M'
          f.gsub!(/(?<!%)m{2}/, '%M')
          f.gsub!(/(?<!%)m{1}/, '%-M')
          # Java 'h' (hour in am/pm, 1-12) to Ruby '%I'
          f.gsub!(/(?<!%)h{2}/, '%I')
          f.gsub!(/(?<!%)h{1}/, '%-I')
          # Java 's' (second in minute) to Ruby '%S'
          f.gsub!(/(?<!%)s{1,}/, '%S')
          # Java 'a' (am/pm marker) to Ruby '%p'
          f.gsub!(/(?<!%)a/, '%p')
          # Java 'K' (hour in am/pm, 0-11) to Ruby '%l'
          f.gsub!(/(?<!%)K{2}/, '%l')
          f.gsub!(/(?<!%)K{1}/, '%-l')
          # Java 'S' (fractional seconds, milliseconds) to Ruby '%L'
          f.gsub!(/(?<!%)S{1,}/, '%L')
          # Java 'z' (general time zone) to Ruby '%Z'
          f.gsub!(/(?<!%)z{1,}/, '%Z')
          # Java 'Z' (RFC 822 time zone) to Ruby '%z'
          f.gsub!(/(?<!%)Z{1,}/, '%z')
          # Java 'X' (ISO 8601 time zone) to Ruby '%z'
          f.gsub!(/(?<!%)X{1,}/, '%z')
          # Java 'G' (era designator) - no direct Ruby equivalent, remove or leave as is
          f.gsub!(/(?<!%)G+/, '%G')
          # Java 'Q' (quarter) - no direct Ruby equivalent, remove or leave as is
          f.gsub!(/(?<!%)Q+/, '')
          # Java 'F' (day of week in month) - no direct Ruby equivalent, remove or leave as is
          f.gsub!(/(?<!%)F+/, '')
          # Java 'c' (stand-alone day of week) - no direct Ruby equivalent, remove or leave as is
          f.gsub!(/(?<!%)c+/, '')
          # Java 'L' (stand-alone month) - treat as month
          f.gsub!(/(?<!%)L{4,}/, '%B')
          f.gsub!(/(?<!%)L{3}/, '%b')
          f.gsub!(/(?<!%)L{1,2}/, '%m')
          f
        end
      end

      # Time provides the time generator which will give the current time in the defined format
      class TimeGenerator < DateGenerator
        def type
          'Time'
        end

        def matcher_type
          'time'
        end

        def default_format
          'HH:mm'
        end
      end

      class DateTimeGenerator < DateGenerator
        def type
          'DateTime'
        end

        def matcher_type
          'datetime'
        end

        def default_format
          'yyyy-MM-dd HH:mm'
        end
      end

      class RandomBooleanGenerator
        include Base

        def initialize(example: nil)
          @example = example
        end

        def as_basic
          {
            "pact:matcher:type" => "boolean",
            "pact:generator:type" => "RandomBoolean",
            "value" => @example.nil? ? [true, false].sample : @example
          }
        end
      end

      class ProviderStateGenerator
        include Base

        def initialize(expression:)
          @expression = expression
        end

        def as_basic
          {
            "pact:generator:type" => "ProviderState",
            "expression" => @expression
          }
        end
      end

      class MockServerURLGenerator
        include Base

        def initialize(regex:, example:)
          @regex = regex
          @example = example
        end

        def as_basic
          {
            "pact:generator:type" => "MockServerURL",
            "pact:matcher:type" => "regex",
            "regex" => @regex,
            "example" => @example,
            "value" => @example
          }
        end
      end
    end
  end
end
