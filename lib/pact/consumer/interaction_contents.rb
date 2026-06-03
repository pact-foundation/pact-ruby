# frozen_string_literal: true

module Pact
  module Consumer
    class InteractionContents < Hash
      BASIC_FORMAT = :basic
      PLUGIN_FORMAT = :plugin

      attr_reader :format

      def self.basic(contents_hash)
        new(contents_hash, BASIC_FORMAT)
      end

      def self.plugin(contents_hash)
        new(contents_hash, PLUGIN_FORMAT)
      end

      def initialize(contents_hash, format)
        serialized = init_hash(contents_hash, format)
        # A scalar body (plain string, integer, etc.) serializes to a non-Hash
        # value that cannot be merged pair by pair; expose it via #value instead.
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

      def serialize(hash, format)
        # serialize recursively
        if hash.is_a?(Pact::Matchers::Base) || hash.is_a?(Pact::Generators::Base)
          return hash.as_basic if format == :basic
          return hash.as_plugin if format == :plugin
        end

        return hash.map { |value| serialize(value, format) } if hash.is_a?(Array)

        # A value that is not a collection or a matcher/generator has nothing to
        # recurse into, so return it unchanged (string, integer, boolean, nil, ...).
        return hash unless hash.is_a?(Hash)

        hash.each_pair do |key, value|
          hash[key] = serialize(value, format)
        end

        hash
      end

      def init_hash(hash, format)
        serialize(hash.deep_dup, format)
      end
    end
  end
end
