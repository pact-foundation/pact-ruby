# frozen_string_literal: true

module Pact
  module Matchers
    PACT_SPEC_V1 = 1
    PACT_SPEC_V2 = 2
    PACT_SPEC_V3 = 3
    PACT_SPEC_V4 = 4

    ANY_STRING_REGEX = /.*/
    UUID_REGEX = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i

    # simplified
    ISO8601_REGEX = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)*(.\d{2}:\d{2})*/i

    def match_exactly(arg)
      V1::Equality.new(arg)
    end

    def match_type_of(arg)
      V2::Type.new(arg)
    end

    def match_include(arg)
      V3::Include.new(arg)
    end

    def match_any_string(sample = "any")
      V2::Regex.new(ANY_STRING_REGEX, sample)
    end

    def match_any_integer(sample = 10)
      V3::Integer.new(sample)
    end

    def match_any_decimal(sample = 10.0)
      V3::Decimal.new(sample)
    end

    def match_any_number(sample = 10.0)
      V3::Number.new(sample)
    end

    def match_any_boolean(sample = true)
      V3::Boolean.new(sample)
    end

    def match_uuid(sample = "e1d01e04-3a2b-4eed-a4fb-54f5cd257338")
      V2::Regex.new(UUID_REGEX, sample)
    end

    def match_regex(regex, sample)
      V2::Regex.new(regex, sample)
    end

    def match_datetime(format, sample)
      V3::DateTime.new(format, sample)
    end

    def match_iso8601(sample = "2024-08-12T12:25:00.243118+03:00")
      V2::Regex.new(ISO8601_REGEX, sample)
    end

    def match_date(format, sample)
      V3::Date.new(format, sample)
    end

    def match_time(format, sample)
      V3::Time.new(format, sample)
    end

    def match_each(template, min = nil)
      V3::Each.new(template, min)
    end

    def match_each_regex(regex, sample)
      match_each_value(sample, match_regex(regex, sample))
    end

    def match_each_key(template, key_matchers)
      V4::EachKey.new(key_matchers.is_a?(Array) ? key_matchers : [key_matchers], template)
    end

    def match_each_value(template, value_matchers = V2::Type.new(""))
      V4::EachValue.new(value_matchers.is_a?(Array) ? value_matchers : [value_matchers], template)
    end

    def match_each_kv(template, key_matchers)
      V4::EachKeyValue.new(key_matchers.is_a?(Array) ? key_matchers : [key_matchers], template)
    end

    def match_semver(template = nil)
      V3::Semver.new(template)
    end

    def match_content_type(content_type, template = nil)
      V3::ContentType.new(content_type, template: template)
    end

    def match_not_empty(template = nil)
      V4::NotEmpty.new(template)
    end

    def match_status_code(template)
      V4::StatusCode.new(template)
    end
  end
end
