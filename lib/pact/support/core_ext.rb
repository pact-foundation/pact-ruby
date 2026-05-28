# frozen_string_literal: true

# Minimal active_support polyfills for blank?/present? and deep_dup.
# Each block is skipped entirely if the method is already defined
# (e.g. active_support is loaded by the host application).

unless Object.method_defined?(:blank?)
  class NilClass
    def blank? = true
    def present? = false
  end

  class FalseClass
    def blank? = true
    def present? = false
  end

  class TrueClass
    def blank? = false
    def present? = true
  end

  class String
    def blank? = empty? || strip.empty?
    def present? = !blank?
  end

  class Array
    def blank? = empty?
    def present? = !empty?
  end

  class Hash
    def blank? = empty?
    def present? = !empty?
  end

  class Object
    def blank? = respond_to?(:empty?) ? !!empty? : !self
    def present? = !blank?

    def presence
      self if present?
    end
  end
end

unless Object.method_defined?(:deep_dup)
  class Object
    def deep_dup
      dup
    rescue TypeError
      self
    end
  end

  class Array
    def deep_dup
      map(&:deep_dup)
    end
  end

  class Hash
    def deep_dup
      each_with_object({}) { |(k, v), h| h[k.deep_dup] = v.deep_dup }
    end
  end
end
