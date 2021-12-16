module Pact
  module HashRefinements
    refine Hash do
      def compact
        h = {}
        each do |key, value|
          h[key] = value unless value == nil
        end
        h
      end unless Hash.method_defined? :compact

      def compact!
        reject! {|_key, value| value == nil}
      end unless Hash.method_defined? :compact!
    end
  end
end
