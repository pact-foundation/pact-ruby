# Can't use refinements because of Travelling Ruby

module Pact
  module Utils
    module String

      extend self

      # ripped from rubyworks/facets, thank you
      def camelcase(string, *separators)
        case separators.first
        when Symbol, TrueClass, FalseClass, NilClass
          first_letter = separators.shift
        end

        separators = ['_', '\s'] if separators.empty?

        str = string.dup

        separators.each do |s|
          str = str.gsub(/(?:#{s}+)([a-z])/){ $1.upcase }
        end

        case first_letter
        when :upper, true
          str = str.gsub(/(\A|\s)([a-z])/){ $1 + $2.upcase }
        when :lower, false
          str = str.gsub(/(\A|\s)([A-Z])/){ $1 + $2.downcase }
        end

        str
      end
    end
  end
end