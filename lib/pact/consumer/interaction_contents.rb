# frozen_string_literal: true

module Pact
  module Consumer
    class InteractionContents < Hash
      BASIC_FORMAT = :basic
      PLUGIN_FORMAT = :plugin

      attr_reader :format, :matching_rules

      def self.basic(contents_hash)
        new(contents_hash, BASIC_FORMAT)
      end

      def self.plugin(contents_hash)
        new(contents_hash, PLUGIN_FORMAT)
      end

      def initialize(contents_hash, format)
        @matching_rules = {}
        serialized = serialize(contents_hash.deep_dup, format, '$')

        if serialized.is_a?(Hash)
          serialized.each_pair { |k, v| self[k] = v }
        else
          @value = serialized
        end

        @format = format
      end

      def value
        defined?(@value) ? @value : self
      end

      private

      def serialize(value, format, path)
        if value.is_a?(Pact::Matchers::Combined)
          @matching_rules[path] = value.as_matching_rule
          return value.template
        end

        if value.is_a?(Pact::Matchers::Base) ||
           value.is_a?(Pact::Generators::Base)
          return value.as_basic if format == :basic
          return value.as_plugin if format == :plugin
        end

        if value.is_a?(Array)
          return value.each_with_index.map do |item, index|
            serialize(item, format, "#{path}[#{index}]")
          end
        end

        return value unless value.is_a?(Hash)

        value.each_with_object({}) do |(key, child), result|
          result[key] = serialize(child, format, "#{path}.#{key}")
        end
      end
    end
  end
end
