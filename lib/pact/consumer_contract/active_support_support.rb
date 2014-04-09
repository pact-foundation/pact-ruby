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

    # ActiveSupport JSON overwrites (i.e. TRAMPLES) the json methods of the Regexp class directly
    # (beneath its destructive hooves of destruction).
    # This does not seem to be able to be undone without affecting the JSON serialisation in the
    # calling project, so the best way I've found to fix this issue is to reattach the
    # original as_json to the Regexp instances in the ConsumerContract before we write them to the
    # pact file. If anyone can find a better way, please submit a pull request ASAP!
    def fix_regexp regexp
      def regexp.as_json options = {}
        {:json_class => 'Regexp', "o" => self.options, "s" => self.source }
      end
      regexp
    end

    # Having Active Support JSON loaded somehow kills the formatting of pretty_generate for objects.
    # Don't ask me why, but it still seems to work for hashes, so the hacky work around is to
    # reparse the generated JSON into a hash and pretty_generate that... sigh...
    # Oh ActiveSupport, why....
    def fix_json_formatting json
      if json.include?("\n")
        json
      else
        JSON.pretty_generate(JSON.parse(json, create_additions: false))
      end
    end

    def remove_unicode json
      json.gsub(/\\u([0-9A-Za-z]{4})/) {|s| [$1.to_i(16)].pack("U")}
    end

  end
end