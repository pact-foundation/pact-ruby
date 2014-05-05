require 'pact/shared/active_support_support'
require 'json/add/regexp'

module Pact
  class Term

    include Pact::ActiveSupportSupport

    attr_reader :generate, :matcher

    def self.json_create(obj)
      new(generate: obj['data']['generate'], matcher: obj['data']['matcher'])
    end

    def self.unpack_regexps source
      case source
      when Pact::Term then source.matcher
      when Array then unpack_regexps_from_array source
      when Hash then unpack_regexps_from_hash source
      else
        source
      end
    end

    def initialize(attributes = {})
      @generate = attributes[:generate]
      @matcher = attributes[:matcher]
      raise "Please specify a matcher for the Term" unless @matcher != nil
      raise "Please specify a value to generate for the Term" unless @generate != nil
      raise "Value to generate \"#{@generate}\" does not match regular expression #{@matcher}" unless @generate =~ @matcher
    end

    def to_hash
      { json_class: self.class.name, data: { generate: generate, matcher: fix_regexp(matcher)} }
    end

    def as_json(options = {})
      to_hash
    end


    def to_json(options = {})
      as_json.to_json(options)
    end

    def match(literal)
      literal.respond_to?(:to_s) ? matcher.match(literal.to_s) : nil
    end

    def ==(other)
      return false unless other.respond_to?(:generate) && other.respond_to?(:matcher)
      generate == other.generate && matcher == other.matcher
    end

    def to_s
      "Pact::Term matcher: #{matcher.inspect}" + (generate.nil? ? "" : " generate: \"#{generate}\"")
    end

    def diff_with_actual(actual)
      match(actual) ? nil : {
        expected: self,
        actual: actual
      }
    end

    def empty?
      false
    end

    private

    def self.unpack_regexps_from_array source
      source.each_with_object([]) do | item, destination |
        destination << unpack_regexps(item)
      end
    end

    def self.unpack_regexps_from_hash source
      source.keys.each_with_object({}) do | key, destination |
        destination[key] = unpack_regexps source[key]
      end
    end

  end
end
