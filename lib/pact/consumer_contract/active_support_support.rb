module Pact
  module ActiveSupportSupport

    extend self

    def fix_all_the_things thing
      if thing.is_a?(Regexp)
        fix_regexp(thing)
      elsif thing.is_a?(Array)
        thing.each{ | it | fix_all_the_things it }
      elsif thing.is_a?(Hash)
          thing.values.each{ | it | fix_all_the_things it }
      elsif thing.class.name.start_with?("Pact")
        thing.instance_variables.collect{ | iv_name | thing.instance_variable_get(iv_name)}.each do | iv |
          fix_all_the_things iv
        end
      end
      thing
    end

    def fix_regexp regexp
      def regexp.as_json options = {}
        {:json_class => 'Regexp', "o" => self.options, "s" => self.source }
      end
      regexp
    end

  end
end