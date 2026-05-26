# frozen_string_literal: true

# Minimal blank?/present? polyfill for when active_support is not loaded.
# Skipped entirely if Object already responds to blank? (e.g. active_support is present).
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
    def blank? = !self
    def present? = !!self
  end
end
