# frozen_string_literal: true

module Pact
  module V2
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
          init_hash(contents_hash, format).each_pair { |k, v| self[k] = v }
          @format = format
        end

        private

        def serialize(hash, format)
          # serialize recursively
          if hash.is_a?(String)
            return hash
          end
          if hash.is_a?(Pact::V2::Matchers::Base)
            return hash.as_basic if format == :basic
            return hash.as_plugin if format == :plugin
          end
          if hash.is_a?(Pact::V2::Generators::Base)
            return hash.as_basic if format == :basic
            return hash.as_plugin if format == :plugin
          end
          hash.each_pair do |key, value|
            next serialize(value, format) if value.is_a?(Hash)
            next hash[key] = value.map { |v| serialize(v, format) } if value.is_a?(Array)
            if value.is_a?(Pact::V2::Matchers::Base)
              hash[key] = value.as_basic if format == :basic
              hash[key] = value.as_plugin if format == :plugin
            end
            if value.is_a?(Pact::V2::Generators::Base)
              hash[key] = value.as_basic if format == :basic
              hash[key] = value.as_plugin if format == :plugin
            end
          end

          hash
        end

        def init_hash(hash, format)
          serialize(hash.deep_dup, format)
        end
      end
    end
  end
end
