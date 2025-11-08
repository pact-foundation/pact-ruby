# frozen_string_literal: true

module Pact
  module Matchers
    module V3
      class ContentType < Pact::Matchers::Base
        def initialize(content_type, template: nil)
          @content_type = content_type
          @template = template
          @opts = {}
          @opts[:plugin_template] = template unless template.nil?
          unless content_type.is_a?(String) && !content_type.empty?
            raise MatcherInitializationError, "#{self.class}: content_type must be a non-empty String"
          end

          super(
            spec_version: Pact::Matchers::PACT_SPEC_V3,
            kind: 'contentType',
            template: content_type,
            opts: @opts
          )
        end

        def as_plugin
          "matching(contentType, '#{@content_type}', '#{@opts[:plugin_template]}')"
        end
      end
    end
  end
end
