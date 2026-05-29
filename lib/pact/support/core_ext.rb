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
    BLANK_RE = /\A[[:space:]]*\z/

    def blank?
      empty? || BLANK_RE.match?(self)
    end

    def present? = !blank?
  end

  class Symbol
    alias_method :blank?, :empty?
    def present? = !blank?
  end

  class Array
    alias_method :blank?, :empty?
    def present? = !empty?
  end

  class Hash
    alias_method :blank?, :empty?
    def present? = !empty?
  end

  class Object
    def blank? = respond_to?(:empty?) ? !!empty? : false
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
      hash = dup
      each_pair do |key, value|
        if ::String === key || ::Symbol === key
          hash[key] = value.deep_dup
        else
          hash.delete(key)
          hash[key.deep_dup] = value.deep_dup
        end
      end
      hash
    end
  end

  class Module
    def deep_dup
      name.nil? ? super : self
    end
  end
end
